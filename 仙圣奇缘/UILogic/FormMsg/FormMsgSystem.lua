--------------------------------------------------------------------------------------
-- 文件名:	FormMsgSystem.lua
-- 版  权:	(C)深圳美天互动科技有限公司
-- 创建人:	lixu
-- 日  期:	2015-5-6
-- 版  本:	1.0
-- 描  述:	界面逻辑 跟 数据层 解耦合( id 定义在 formmsgid.lua中  回调函数 function funcall(context) .... end)
-- 应  用:   
---------------------------------------------------------------------------------------

g_LoadFile("LuaScripts/UILogic/FormMsg/FormMsgID")

FormMsgSystem = class("FormMsgSystem")
FormMsgSystem.__index = FormMsgSystem

function FormMsgSystem:ctor()
	self.tbListen = {} 	-- 数据结构 tbListen[id]= func

	self.tbMsg = {} 	--消息队列 tbMsg{ {id, context},..}
end

function FormMsgSystem:RegisterFormMsg(Formid, func)
	if Formid == nil or func == nil then
		return false
	end

	self.tbListen[Formid] = {}
	self.tbListen[Formid].funcall = func

	return true
end

function FormMsgSystem:UnRegistFormMsg(Formid)
	self.tbListen[Formid] = nil
end

--下一贞 执行
function FormMsgSystem:SendFormMsg(Formid, context)

	self.tbMsg = self.tbMsg == nil or {} and self.tbMsg
	local tb = {}
	if type(context) == "table" then
		tb.context = {}
	end
	tb.Formid = Formid
	tb.context = context
	table.insert(self.tbMsg, tb)
end

--立刻  执行
function FormMsgSystem:PostFormMsg(Formid, context)
	self:ErgodicMsg(Formid, context)
end

function FormMsgSystem:ErgodicMsg(Formid, context)
	if self.tbListen[Formid] ~= nil then
		self.tbListen[Formid].funcall(context)
	end
end

function FormMsgSystem:UpdateMsg()
	if table.getn(self.tbMsg) == 0 then
		return
	end

	for k, v in pairs(self.tbMsg)do
		self:ErgodicMsg(v.Formid, v.context)
	end

	--每贞过后 清空消息队列
	self.tbMsg = {}
	return
end

function FormMsgSystem:RegistTimeCall()
	g_Timer:pushLoopTimer(0, handler(self, self.UpdateMsg))
end


---全局对象
g_FormMsgSystem = FormMsgSystem.new()