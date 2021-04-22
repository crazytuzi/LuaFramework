
local QFileCache = class("QFileCache")

function QFileCache:sharedFileCache()
	if app._fileCache == nil then
        app._fileCache = QFileCache.new()
    end
    return app._fileCache
end

function QFileCache:ctor(options)
	-- ai
	self._aiConfigCache = {}
    self._aiClassCache = {}

    -- skill behavior
    self._skillConfigCache = {}
    self._skillClassCache = {}

    -- display behavior
    self._displayConfigCache = {}
    self._displayClassCache = {}
end

function QFileCache:_getFileContent(name, path, cacheTable)
    if name == nil or string.len(name) == 0 then
        return nil
    end

    if path == nil then
        return nil
    end

    if cacheTable == nil then
        return nil
    end

    local content = cacheTable[name]
    if content == nil then
        content = import(".." .. path .. "." .. name, "app.utils.QFileCache")
        if content ~= nil then
            cacheTable[name] = content
        end
    end

    return content
end

function QFileCache:getAIConfigByName(name)
    local config = self:_getFileContent(name, "ai.config", self._aiConfigCache)
    assert(config ~= nil, " ai config file named: " .. tostring(name) .. " does not exist.")
    return config
end

function QFileCache:getAIClassByName(name)
    local classObj = self:_getFileContent(name, "ai", self._aiClassCache)
    assert(classObj ~= nil, "the AI class named: " .. tostring(name) .. " does not exist.")
    return classObj
end

function QFileCache:getSkillConfigByName(name)
    local config = self:_getFileContent(name, "skill.config", self._skillConfigCache)
    assert(config ~= nil, " skill config file named: " .. tostring(name) .. " does not exist.")
    return config
end

function QFileCache:getSkillClassByName(name)
    local classObj = self:_getFileContent(name, "skill", self._skillClassCache)
    assert(classObj ~= nil, "the skill class named: " .. tostring(name) .. " does not exist.")
    return classObj
end

function QFileCache:getDisplayConfigByName(name)
    local config = self:_getFileContent(name, "ui.widgets.actorDisplay.config", self._displayConfigCache)
    assert(config ~= nil, " display config file named: " .. tostring(name) .. " does not exist.")
    return config
end

function QFileCache:getDisplayClassByName(name)
    local classObj = self:_getFileContent(name, "ui.widgets.actorDisplay", self._displayClassCache)
    assert(classObj ~= nil, "the display class named: " .. tostring(name) .. " does not exist.")
    return classObj
end

return QFileCache
