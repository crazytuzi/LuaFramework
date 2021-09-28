

local Helper = require 'Zeus.Logic.Helper'
local Util = require 'Zeus.Logic.Util'
local ItemModel = require 'Zeus.Model.Item'
local _M = {}
_M.__index = _M

function _M.SendEndMsg(parent)
	local r = parent:GetRootEvent()
	DramaHelper.SendDramaEndToBattle(r.name)
end

function _M.SetNeedSendEndMsg(parent)
	local r = parent:GetRootEvent()
	r:SetAttribute('NeedSendEndMsg',true)
end

function _M.GetDistance(parent,x1,y1,x2,y2)
  local r1 = x1 - x2;
  local r2 = y1 - y2;
  return math.sqrt(r1 * r1 + r2 * r2)
end

function _M.GetText(parent,key,...)
	
	return Util.GetText(TextConfig.Type.GUIDE,key,...)
end

function _M.CheckFuncOpen(parent,name)
	return GlobalHooks.CheckFuncOpenByName(name,false)
end

function _M.GetItemStaticData(parent,code)
	return ItemModel.GetItemStaticDataByCode(code)
end

function _M.GetQualityColorRGBA(parent,qColor)
	return Util.GetQualityColorRGBA(qColor)
end

function _M.IsInDungeon()
	local sceneType = PublicConst.SceneTypeInt2Enum(DataMgr.Instance.UserData.SceneType)
	return sceneType == PublicConst.SceneType.Dungeon
end

function _M.GetProKey(parent)
	local userData = DataMgr.Instance.UserData
	local pros = {
		'苍狼','御剑','逸仙','神箭','令狐'
	}
	return pros[userData.Pro]
end

function _M.GetUserInfo(parent)
	local userData = DataMgr.Instance.UserData
	local pt = userData.Position
	local ret = {
		name = userData.Name,
		pro = userData.Pro,
		lv = userData:GetAttribute(UserData.NotiFyStatus.LEVEL),
		upLv = userData:GetAttribute(UserData.NotiFyStatus.UPLEVEL),
		sceneId = userData.SceneId,
		sceneType = userData.SceneType,
		x = pt.x,
		y = pt.y,
		direction = userData.Direction,
		hp = userData:GetAttribute(UserData.NotiFyStatus.HP),
		mp = userData:GetAttribute(UserData.NotiFyStatus.MP),
		
	}
	return ret
end

function _M.PauseUser(parent)
    GameSceneMgr.Instance.BattleRun.BattleClient:PauseSeek()
end

function _M.ResumeUser(parent)
    GameSceneMgr.Instance.BattleRun.BattleClient:ResumeSeek()
end

function _M.PlayerDeliveryPosByQuestID(parent,questID)
    DataMgr.Instance.QuestManager:transferScene(questID)
end


function _M._asyncShowCaption(self, t)
	local info = DramaCaptionU.CaptionInfo.New()
	info.Name = t.name or "Undefined"
	
	if t.iconPath then
		info.IconPath = t.iconPath
	end
	info.EndCB = LuaHelper.Action(function ()
		self:Done()
	end)
	info.WaitSec = t.wait or 0.5
	for _,v in ipairs(t.texts) do
		info:AddText(v.text, v.sec or 0, v.clean or false, v.wait or 0)
	end
	DramaUIManage.Instance:AddCaption(info)
	local r = self:GetRootEvent()
	local lastInfos = r:GetAttribute('CaptionInfo')
	if not lastInfos then
		lastInfos = {}
		r:SetAttribute('CaptionInfo',lastInfos)
	end
	table.insert(lastInfos,info)

	self:SetAttribute('CaptionInfo',info)
	self:Await()
end

function _M.AddCaptionText(parent, sc_id, v)
	local e = parent:GetEvent(sc_id)
	if e then
		local info = e:GetAttribute('CaptionInfo')
		if info then
			info:AddText(v.text, v.sec or 0, v.clean or false, v.wait or 0)
		end
	end
end

function _M.PlayGuideSoundByKey(parent,key)
	local path = Util.GetText(TextConfig.Type.SOUND,key)
	GlobalHooks.playTalkVoice(path)
end

function _M.playTalkVoice(parent,path)
    GlobalHooks.playTalkVoice(path)
end

function _M.PlaySoundByKey(parent,key)
	XmdsSoundManager.GetXmdsInstance():PlaySoundByKey(key)
end

function _M.PlaySound(parent,res)
	XmdsSoundManager.GetXmdsInstance():PlaySound(res)
end

function _M.PlaySoundExt(parent,res)
	local r = parent:GetRootEvent()
	local source = GameUtil.Play2DSound(res)
	return r:AddCacheduserdata(source, 'UnityEngine.AudioSource')
end

function _M.StopSound(parent,tag)
	local r = parent:GetRootEvent()
	local source,type_str = r:GetCacheduserdata(tag)
	if not source then return end
	if type_str == 'UnityEngine.AudioSource' then
		XmdsSoundManager.GetXmdsInstance():ReleaseAudioSource(source)
	end
end

function _M.StopSoundBySource(parent,source)
    XmdsSoundManager.GetXmdsInstance():stopClipSource(source)
end

function _M.PlaySoundByKeyExt(parent,key)
	local r = parent:GetRootEvent()
	local source = GameUtil.Play2DSoundByKey(key)
	return r:AddCacheduserdata(source, 'UnityEngine.AudioSource')
end

function _M.PlayBGM(parent,path)
	local r = parent:GetRootEvent()
	r:SetAttribute('CurrentBGMName',XmdsSoundManager.GetXmdsInstance().CurrentBGMName)
	XmdsSoundManager.GetXmdsInstance():PlayBGM(path)
end

function _M.StopBGM(parent)
	local r = parent:GetRootEvent()
	if not r:HasAttribute('CurrentBGMName') then
		r:SetAttribute('CurrentBGMName',XmdsSoundManager.GetXmdsInstance().CurrentBGMName)
	end
	XmdsSoundManager.GetXmdsInstance():StopBGM()
end

function _M.IsBlockTouch(parent)
	local r = parent:GetRootEvent()
	return r:HasAttribute('SetBlockTouch')
end

function _M.SetBlockTouch(parent,var,id,alpha)
	local r = parent:GetRootEvent()
	
	if var then
		if id then 
			
			r:SetTimeout(-1)
			local	trans = r:GetCacheduserdata(id)
			if not alpha then
				DramaHelper.SetBlockTouch(true,trans)
			else
				DramaHelper.SetBlockTouch(true,trans,alpha)
			end
		else
			
			
			
			
			
			
			
			
			
			r:SetTimeout(120)
			DramaHelper.SetBlockTouch(true)
		end
		r:SetAttribute('SetBlockTouch',true)
	else
		r:SetTimeout(-1)
		DramaHelper.SetBlockTouch(false)
		r:SetAttribute('SetBlockTouch',nil)
	end
end

function _M.SetHandAnimation(parent,id)
	local r = parent:GetRootEvent()
	if id then
		local trans = r:GetCacheduserdata(id)
		DramaHelper.ShowGuideHand(trans,true)
	end
end

function _M.ClearGuideBiStep(parent)
	DramaHelper.ClearGuideBiStep()
end

function _M.SetGuideBiStep(parent,step)
	local r = parent:GetRootEvent()
	if r and step then
		DramaHelper.SetGuideBiStep(r.name,step)
	end
end

function _M.StartGuideScript(parent,script,var)
	GlobalHooks.Drama.Start(script, var)
end

function _M.ShowSideTool(parent,var)
	local r = parent:GetRootEvent()
	local env = r:GetAttribute('__env')
	if not r:HasAttribute('ShowSideTool') and var then
		env.ShowSideTool(true,function ()
			parent:GetRootEvent():Done()
		end)
		r:SetAttribute('ShowSideTool',true)
	elseif not var then
		env.ShowSideTool(false)
		r:SetAttribute('ShowSideTool',nil)
	end
end

function _M._asyncWaitGameObjExit(self,id)
	local obj = UnityEngine.GameObject.Find(id)
	if not obj then 
		self:Done() 
	end
	self:AddTimer(function (delta)
		if obj.activeSelf == false then
			self:Done()
		end
	end,0,false)
	self:Await()
end

function _M.CloseCaption(parent)
	print('CloseCaptionCloseCaptionCloseCaption')
	DramaUIManage.Instance:CloseCaption()
	parent:GetRootEvent():SetAttribute('CaptionInfo',nil)
end

function _M._asyncFadeOutBackImg(self,sec)
	DramaUIManage.Instance:FadeOutBackImg(sec)
	self:AddTimer(function (delta)
		self:Done()
	end,sec,true)
	self:Await()
end

function _M._asyncFadeInBackImg(self,sec)
	DramaUIManage.Instance:FadeInBackImg(sec)
	self:AddTimer(function (delta)
		self:Done()
	end,sec,true)
	self:Await()
end

function _M.CopyTable(parent,t)
	return Helper.copy_table(t)
end




function _M.CallGlobalFunc(parent, funcstr, ...)
	local list = string.split(funcstr,'.')
	local func = _G
	for k,v in ipairs(list) do
		func = func[v]
	end
	if type(func) == 'function' then
		local ret
		local params = {...}
		print('CallGlobalFunc',funcstr,...)
		parent:AddTimer(function (delta)
			ret = {func(unpack(params))}
		end,0,true)
		parent:Await(0)
		return unpack(ret)
	end
end

function _M.ToggleDebugModel(parent,var)
	DramaHelper.ToggleDebugModel(var)
end

function _M.FireEvent(parent,eventName,...)
	print('FireEvent',eventName,...)
	EventManager.Fire(eventName,...)
end


function _M.FindBagItemByCode(parent,code)
	local it = DataMgr.Instance.UserData.RoleBag:GetTemplateItem(code)
	if not it then return nil end
	return {id=it.Id,num=it.Num,index=it.Index,star=it.StarNum}
end


function _M._asyncSendChatMsg(self, content, params)
	params = params or {}
	local input = {
		s2c_isAtAll = 0,
		s2c_pro = DataMgr.Instance.UserData.Pro,
		s2c_color = 3890598399,
		s2c_level = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.LEVEL),
		s2c_titleMsg = '',
		acceptRoleId = params.acceptRoleId or '',
		s2c_zoneId = DataMgr.Instance.UserData:GetAttribute(UserData.NotiFyStatus.ZONEID),
		s2c_name = DataMgr.Instance.UserData.Name,
		s2c_vip = 0,
	}
	local cjson = require "cjson"
	local msg = cjson.encode(input)
	FileSave.serverData = msg
	FileSave.channel = params.channel or '1'
	FileSave.chatContent = content
	
	self:AddTimer(function (delta)
		
		FileSave.CallBack = function (issend)
			self:Done()
		end
		FileSave.SendMsgData()
	end,0,true)	
	
	self:Await()
end




function _M.SetTimeScale(parent, scale)	
	local r = parent:GetRootEvent()
	if not r:HasAttribute('SetTimeScale') then
		r:SetAttribute('SetTimeScale',Time.timeScale)
	end
	Time.SetTimeScale(scale)
end

function _M.ShowNotify(parent,content,rgba,x,y)
	if rgba and not x then
		GameAlertManager.Instance:ShowNotify(content,rgba)
	elseif rgba and x and y then
		GameAlertManager.Instance:ShowNotify(content,rgba,Vector2.New(x,y))
	else
		GameAlertManager.Instance:ShowNotify(content)
	end
end

function _M.SetHudMaskTouchEnable(parent,var)
	EventManager.Fire("Event.SetHudMaskTouchEnable",{value = var})
end

function _M.Clear(parent)
	local r = parent:GetRootEvent()
	local infos = r:GetAttribute('CaptionInfo')
	for _,v in ipairs(infos or {}) do
		DramaUIManage.Instance:RemoveCaption(v)
	end

	if infos and #infos > 0 then
		DramaUIManage.Instance:CloseCaption()
	end
	local env = r:GetAttribute('__env')
	if r:HasAttribute('ShowSideTool') then
		env.ShowSideTool(false)
	end

	if r:HasAttribute('SetBlockTouch') then
		DramaHelper.SetBlockTouch(false)
	end

	local scale = r:GetAttribute('SetTimeScale')
	if scale then
		Time.SetTimeScale(scale)
	end

	local bgm = r:GetAttribute('CurrentBGMName')
	if bgm then
		XmdsSoundManager.GetXmdsInstance():PlayBGM(bgm)
	end
	
	local NeedSendEndMsg = r:GetAttribute('NeedSendEndMsg')
	if NeedSendEndMsg or r.params[1] == "AOI" then
		DramaHelper.SendDramaEndToBattle(r.name)
	end
	
	r:ForeachCacheduserdata(function (id,obj,type_str)
		if type_str == 'UnityEngine.AudioSource' then
			XmdsSoundManager.GetXmdsInstance():ReleaseAudioSource(obj)
		end
	end)
end

return _M
