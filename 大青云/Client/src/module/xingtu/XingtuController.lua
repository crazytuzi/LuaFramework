--[[
星图
yujia
]]

_G.XingtuController = setmetatable({},{__index=IController});
XingtuController.name = "XingtuController";

function XingtuController:Create()
	MsgManager:RegisterCallBack(MsgType.SC_StarOperResult,self,self.LvUpResult);
	MsgManager:RegisterCallBack(MsgType.SC_StarUpdate,self,self.StarInfoUpdate);
end

-- <list type="starVo" name="starlist" comment="星图列表" index="1">
-- 	<attribute type="int" name="id" comment="星图id，1-28"/>
-- 	<attribute type="int" name="lv" comment="星图重数，1-3"/>
-- 	<attribute type="int" name="pos" comment="星图位置，1-7"/>
-- </list>
function XingtuController:StarInfoUpdate(msg)
	for k, v in pairs(msg.starlist or {}) do
		XingtuModel:Updatainfo(v.id, v.lv, v.pos)
	end
end


-- <attribute type="int" name="result" comment="错误码"/>
-- <attribute type="int" name="oper" comment="1=手动，2=自动"/>
-- <attribute type="int" name="id" comment="星图id，1-28"/>
-- <attribute type="int" name="lv" comment="星图重数，1-3"/>
-- <attribute type="int" name="pos" comment="星图位置，1-7"/>
function XingtuController:LvUpResult(msg)
	if msg.result == 2050007 then
		Notifier:sendNotification(NotifyConsts.XingtuLvUpResultFail, {msg.oper, msg.id, msg.lv, msg.pos})
		return
	end
	if msg.result == 0 then
		Notifier:sendNotification(NotifyConsts.XingtuLvUpResult, {msg.oper, msg.id, msg.lv, msg.pos})
	end
end

function XingtuController:AskLvUp(id, isAuto)
	local msg = ReqStarOperMsg:new()
	msg.oper = isAuto and 2 or 1
	msg.id = id
	MsgManager:Send(msg)
end;