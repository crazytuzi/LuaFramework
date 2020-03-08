local Lplus = require("Lplus")
local CG = require("CG.CG")
local ECModel = require("Model.ECModel")
local CGEventPlayAni = Lplus.Class("CGEventPlayAni")
local def = CGEventPlayAni.define
local s_inst
def.static("=>", CGEventPlayAni).Instance = function()
  if not s_inst then
    s_inst = CGEventPlayAni()
  end
  return s_inst
end
def.method("table", "table", "userdata").DramaEvent_Start = function(self, dataTable, dramaTable, eventObj)
  local ecModel = dramaTable[dataTable.id]
  if ecModel then
    do
      local function cb(aniname)
        print("playani:", aniname, " id:", dataTable.id)
        local state = ecModel.m_ani:State(aniname)
        state.speed = dataTable.speed
        state.wrapMode = dataTable.loop
        local start = dataTable.starttime
        if start < 0 then
          start = 0
        end
        if start > 1 then
          start = 1
        end
        state.time = start * state.length
        local endtime = dataTable.endtime
        if endtime < 0 then
          endtime = 0
        end
        if endtime > 1 then
          endtime = 1
        end
        if dataTable.loop == 2 then
          endtime = 0
        else
          endtime = endtime * state.length
        end
        ecModel:CrossFade(aniname, 0.1)
        print("endtime:", aniname, " ", endtime)
        return endtime
      end
      if dataTable.extraAni and dataTable.resourceID > 0 then
        do
          local aniFilename = datapath.GetPathByID(dataTable.resourceID)
          local function loaded(obj)
            if eventObj.isnil then
              return
            end
            if dataTable.isFinished then
              eventObj:Finish()
              return
            end
            if not obj then
              Debug.LogError("EventPlayAni:failed to load ani:" .. aniFilename)
              eventObj:Finish()
              return
            end
            local aniclip = Object.Instantiate(obj, "AnimationClip")
            local aniname = "custom" .. tostring(dataTable.id)
            ecModel.m_ani:AddClip(aniclip, aniname)
            local endtime = cb(aniname)
            eventObj:SetEndTime(endtime)
          end
          GameUtil.AsyncLoad(aniFilename, loaded)
        end
      else
        local endtime = cb(dataTable.animation)
        eventObj:SetEndTime(endtime)
      end
    end
  end
end
def.method("table", "table", "userdata").DramaEvent_Release = function(self, dataTable, dramaTable, eventObj)
  dataTable.isFinished = true
end
CGEventPlayAni.Commit()
CG.RegEvent("CGLuaEventPlayAni", CGEventPlayAni.Instance())
return CGEventPlayAni
