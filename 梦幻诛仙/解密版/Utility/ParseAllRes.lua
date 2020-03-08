local load = function(path, clear, onFinish)
  if utility.IsFileExist(path) then
    if path:find("%.u3dext$") then
      GameUtil.AsyncLoad(path, function(obj)
        if obj and getmetatable(obj).name == "GameObject" then
          local t = Object.Instantiate(obj, "GameObject")
          Object.DestroyImmediate(t, true)
        end
        onFinish()
      end)
      return
    end
  else
    warn("missing file: " .. path)
  end
  onFinish()
end
function _G.parse_all_res()
  print("begin of parse_all_res")
  local load_list = {}
  if datapath.lua_LoadDataPath("data/path.data") then
    local pathnum = datapath.lua_GetIdNum()
    for i = 0, pathnum - 1 do
      local path = datapath.lua_GetPathByID(i)
      load_list[#load_list + 1] = path
    end
    datapath.lua_ReleaseDataPath()
  else
    error("lua_LoadDataPath")
  end
  for k, path in pairs(RESPATH) do
    load_list[#load_list + 1] = path
  end
  local allres = dofile("Lua/Utility/GetResPath.lua", "./")
  for k, path in pairs(allres) do
    load_list[#load_list + 1] = path
  end
  local soundres = dofile("Configs/sound_cfg.lua")
  for k, path in pairs(soundres) do
    load_list[#load_list + 1] = path[1]
  end
  local Lplus = require("Lplus")
  local ECGame = Lplus.ForwardDeclare("ECGame")
  local skillmgr = ECGame.Instance().m_SkillMgr
  for i = 1, 10000 do
    if skillmgr:HasSkillGfx(i) then
      local gfxparam = skillmgr:GetSkillGfx(i)
      if gfxparam ~= nil then
        local gfxpath = gfxparam.FilePath
        load_list[#load_list + 1] = gfxpath
      end
    end
  end
  local function loadAll(load_list, maxConcurrent)
    local nextResIndex = 0
    local function loadNext()
      nextResIndex = nextResIndex + 1
      if nextResIndex % maxConcurrent == 0 then
        print(nextResIndex, #load_list)
        collectgarbage("collect")
        GameUtil.GC()
        Resources.UnloadUnusedAssets()
      end
      local path = load_list[nextResIndex]
      if path then
        GameUtil.AddGlobalTimer(0, true, function()
          load(path, false, loadNext)
        end)
      end
    end
    for i = 1, maxConcurrent do
      loadNext()
    end
  end
  loadAll(load_list, 20)
  local load_map = {}
  local maps = {
    "CreateCharacter",
    "x2",
    "x3",
    "x4",
    "x5",
    "x6",
    "x7",
    "x8",
    "x9",
    "x10",
    "x11",
    "x12",
    "x13",
    "x14",
    "x15"
  }
  for i = 1, #maps do
    local mappreb = "Maps/" .. maps[i] .. ".prefab.u3dext"
    load_map[#load_map + 1] = mappreb
  end
  loadAll(load_map, 1)
  print("end of parse_all_res")
end
