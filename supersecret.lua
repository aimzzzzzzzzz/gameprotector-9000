local Options = {
    include = {
        game:GetService("Workspace"),
        game:GetService("ReplicatedStorage"),
        game:GetService("ReplicatedFirst"),
        game:GetService("StarterGui"),
        game:GetService("StarterPack"),
        game:GetService("Lighting"),
        game:GetService("SoundService"),
        game:GetService("Players")
    },
    usekonstantdecompiler = false,
    save_scripts = true,
    save_in_bin = false,
    nobackup = true,
    exclude_keywords = {"ServerScriptService", "ServerStorage"}
}

local HttpService = game:GetService("HttpService")
local function timestamp() return os.date("%Y-%m-%d_%H-%M-%S") end
local function safeName(str) return tostring(str):gsub("[^%w_]", "_") end
local function isSafe(inst)
    for _, keyword in ipairs(Options.exclude_keywords) do
        if inst:GetFullName():find(keyword) then return false end
    end
    return true
end

local function createFolder(base)
    local folder = "SaveInstance_" .. timestamp()
    if not isfolder(base) then makefolder(base) end
    local path = base .. "/" .. folder
    if not isfolder(path) then makefolder(path) end
    return path
end

local function serializeInstance(inst)
    local props = {}
    for _, p in ipairs({"Name", "ClassName", "Archivable"}) do
        pcall(function()
            props[p] = inst[p]
        end)
    end
    return props
end

local function saveToFile(path, name, content)
    local fileName = path .. "/" .. safeName(name) .. ".txt"
    writefile(fileName, content)
end

local function traverseAndSave(baseFolder, inst)
    if not isSafe(inst) then return end
    local props = serializeInstance(inst)
    local content = "-- Dumped: " .. inst:GetFullName() .. "\n"
    for k, v in pairs(props) do
        content = content .. k .. " = " .. tostring(v) .. "\n"
    end
    saveToFile(baseFolder, inst:GetFullName(), content)

    for _, child in ipairs(inst:GetChildren()) do
        traverseAndSave(baseFolder, child)
    end
end

local function runSave()
    local basePath = "exports"
    local fullPath = createFolder(basePath)
    for _, service in ipairs(Options.include) do
        pcall(function()
            traverseAndSave(fullPath, service)
        end)
    end
end

pcall(runSave)
return true
