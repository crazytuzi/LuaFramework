require "ui.dialog"

YiZhanDaoDiAnswerDlg = {}
setmetatable(YiZhanDaoDiAnswerDlg, Dialog)
YiZhanDaoDiAnswerDlg.__index = YiZhanDaoDiAnswerDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function YiZhanDaoDiAnswerDlg.getInstance()
	-- print("enter get YiZhanDaoDiAnswerDlg dialog instance")
    if not _instance then
        _instance = YiZhanDaoDiAnswerDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function YiZhanDaoDiAnswerDlg.getInstanceAndShow()
	-- print("enter YiZhanDaoDiAnswerDlg dialog instance show")
    if not _instance then
        _instance = YiZhanDaoDiAnswerDlg:new()
        _instance:OnCreate()
	else
		-- print("set YiZhanDaoDiAnswerDlg dialog visible")
		_instance:SetVisible(true)
    end
    
    return _instance
end

function YiZhanDaoDiAnswerDlg.getInstanceNotCreate()
    return _instance
end

function YiZhanDaoDiAnswerDlg.DestroyDialog()
	if _instance then 
		_instance:OnClose()
		_instance = nil
	end
end

function YiZhanDaoDiAnswerDlg.ToggleOpenClose()
	if not _instance then 
		_instance = YiZhanDaoDiAnswerDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end

----/////////////////////////////////////////------

function YiZhanDaoDiAnswerDlg.GetLayoutFileName()
    return "yizhandaodianswer.layout"
end

function YiZhanDaoDiAnswerDlg:OnCreate()
	-- print("YiZhanDaoDiAnswerDlg dialog oncreate begin")
    Dialog.OnCreate(self)

    local winMgr = CEGUI.WindowManager:getSingleton()
    -- get windows
	self.m_pQuestion = winMgr:getWindow("yizhandaodianswer/text")

	self.m_pBtnA = winMgr:getWindow("yizhandaodianswer/choose")
	self.m_pBtnA_text = winMgr:getWindow("yizhandaodianswer/choose/text")
	self.m_pBtnA_num = winMgr:getWindow("yizhandaodianswer/choose/image/text")
	self.m_pBtnAEffect = winMgr:getWindow("yizhandaodianswer/choose/effect")

	self.m_pBtnB = winMgr:getWindow("yizhandaodianswer/choose1")
	self.m_pBtnB_text = winMgr:getWindow("yizhandaodianswer/choose1/text")
	self.m_pBtnB_num = winMgr:getWindow("yizhandaodianswer/choose1/image/text")
	self.m_pBtnBEffect = winMgr:getWindow("yizhandaodianswer/choose1/effect")

	self.m_pBtnC = winMgr:getWindow("yizhandaodianswer/choose2")
	self.m_pBtnC_text = winMgr:getWindow("yizhandaodianswer/choose2/text")
	self.m_pBtnC_num = winMgr:getWindow("yizhandaodianswer/choose2/image/text")
	self.m_pBtnCEffect = winMgr:getWindow("yizhandaodianswer/choose2/effect")

	self.m_pBtnD = winMgr:getWindow("yizhandaodianswer/choose3")
	self.m_pBtnD_text = winMgr:getWindow("yizhandaodianswer/choose3/text")
	self.m_pBtnD_num = winMgr:getWindow("yizhandaodianswer/choose3/image/text")
	self.m_pBtnDEffect = winMgr:getWindow("yizhandaodianswer/choose3/effect")

	self.m_pNextText = winMgr:getWindow("yizhandaodianswer/text1")
	self.m_pNextTime = winMgr:getWindow("yizhandaodianswer/text1/text")
	self.m_pRightNum = winMgr:getWindow("yizhandaodianswer/text3/txt")
	self.m_pViewerNum = winMgr:getWindow("yizhandaodianswer/text4/txt")

	-- set windows
	self.m_pBtnA:setID(1)
	self.m_pBtnB:setID(2)
	self.m_pBtnC:setID(3)
	self.m_pBtnD:setID(4)
	self:Init(self.m_status)
	self.m_pRightNum:setText(tostring(0))
	self.m_pViewerNum:setText(tostring(0))

    -- subscribe event
	self:GetWindow():subscribeEvent("WindowUpdate", YiZhanDaoDiAnswerDlg.HandleWindowUpdate, self)
	self.m_pBtnA:subscribeEvent("MouseButtonDown", YiZhanDaoDiAnswerDlg.HandleBtnClicked, self)
	self.m_pBtnB:subscribeEvent("MouseButtonDown", YiZhanDaoDiAnswerDlg.HandleBtnClicked, self)
	self.m_pBtnC:subscribeEvent("MouseButtonDown", YiZhanDaoDiAnswerDlg.HandleBtnClicked, self)
	self.m_pBtnD:subscribeEvent("MouseButtonDown", YiZhanDaoDiAnswerDlg.HandleBtnClicked, self)

	-- print("YiZhanDaoDiAnswerDlg dialog oncreate end")
end

------------------- private: -----------------------------------


function YiZhanDaoDiAnswerDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, YiZhanDaoDiAnswerDlg)
    return self
end

function YiZhanDaoDiAnswerDlg:Init(status)
	self.m_time = 0
	self.m_answer = 0
	self.m_status = status or 2 -- 1. 选手 2. 观众 3. 结束
	self.m_changeEnable = true
	self.m_pBtnA_num:setText(tostring(0))
	self.m_pBtnB_num:setText(tostring(0))
	self.m_pBtnC_num:setText(tostring(0))
	self.m_pBtnD_num:setText(tostring(0))
	self.m_pBtnAEffect:setVisible(false)
	self.m_pBtnBEffect:setVisible(false)
	self.m_pBtnCEffect:setVisible(false)
	self.m_pBtnDEffect:setVisible(false)
	if self.m_status == 2 then
		self.m_changeEnable = false
		self.m_pBtnA:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
		self.m_pBtnB:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
		self.m_pBtnC:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
		self.m_pBtnD:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
	else
		self.m_pBtnA:setProperty("Image", "set:MainControl31 image:yizhandaodiblue")
		self.m_pBtnB:setProperty("Image", "set:MainControl31 image:yizhandaodiblue")
		self.m_pBtnC:setProperty("Image", "set:MainControl31 image:yizhandaodiblue")
		self.m_pBtnD:setProperty("Image", "set:MainControl31 image:yizhandaodiblue")
	end
end

function YiZhanDaoDiAnswerDlg:InitQuestion(qid, sn)
	self.m_qid = qid
	self.m_sn = sn
	local table = BeanConfigManager.getInstance():GetTableByName("knight.gsp.task.cyizhandaoditiku")
	local record = table:getRecorder(qid)
	if record then
		local q = record.name
		if self.m_sn then
			local strbuilder = StringBuilder:new()
			strbuilder:SetNum("parameter1", self.m_sn)
			local s = strbuilder:GetString(MHSD_UTILS.get_resstring(3051))
			strbuilder:delete()
			q = s .. record.name
		end
		self.m_pQuestion:setText(q)
		self.m_pBtnA_text:setText(record.options[0])
		self.m_pBtnB_text:setText(record.options[1])
		self.m_pBtnC_text:setText(record.options[2])
		self.m_pBtnD_text:setText(record.options[3])
	end
	if self.m_status == 1 then
		self.m_pNextText:setText(MHSD_UTILS.get_resstring(3055))
	else
		self.m_pNextText:setText(MHSD_UTILS.get_resstring(3054))
	end
end

function YiZhanDaoDiAnswerDlg:NewQuestion(qid, sn, status)
	self:Init(status)
	self:InitQuestion(qid, sn)
end

function YiZhanDaoDiAnswerDlg:Refresh(qid, a, b, c, d)
	if self.m_qid and qid == self.m_qid then
		self.m_pBtnA_num:setText(tostring(a))
		self.m_pBtnB_num:setText(tostring(b))
		self.m_pBtnC_num:setText(tostring(c))
		self.m_pBtnD_num:setText(tostring(d))
	else
		self:Init(self.m_status)
		self:InitQuestion(qid)
	end
end

function YiZhanDaoDiAnswerDlg:Result(qid, answer, rightnum, wrongnum, status)
	-- print("YiZhanDaoDiAnswerDlg:Result qid = " .. qid)
	-- print("YiZhanDaoDiAnswerDlg:Result answer = " .. answer)
	-- print("YiZhanDaoDiAnswerDlg:Result rightnum = " .. rightnum)
	-- print("YiZhanDaoDiAnswerDlg:Result wrongnum = " .. wrongnum)
	-- print("YiZhanDaoDiAnswerDlg:Result status = " .. status)
	if not self.m_qid then
		self:Init(self.m_status)
		self:InitQuestion(qid)
		self.m_time = 12
	end
	self.m_status = status

	self.m_pRightNum:setText(rightnum)
	self.m_pViewerNum:setText(wrongnum)
	self.m_pBtnA:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
	self.m_pBtnB:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
	self.m_pBtnC:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
	self.m_pBtnD:setProperty("Image", "set:MainControl31 image:yizhandaodigrey")
	if     self.m_answer == 1 then
		self.m_pBtnAEffect:setVisible(true)
	elseif self.m_answer == 2 then
		self.m_pBtnBEffect:setVisible(true)
	elseif self.m_answer == 3 then
		self.m_pBtnCEffect:setVisible(true)
	elseif self.m_answer == 4 then
		self.m_pBtnDEffect:setVisible(true)
	end
	if     answer == 1 then
		self.m_pBtnA:setProperty("Image", "set:MainControl31 image:yizhandaodigreen")
	elseif answer == 2 then
		self.m_pBtnB:setProperty("Image", "set:MainControl31 image:yizhandaodigreen")
	elseif answer == 3 then
		self.m_pBtnC:setProperty("Image", "set:MainControl31 image:yizhandaodigreen")
	elseif answer == 4 then
		self.m_pBtnD:setProperty("Image", "set:MainControl31 image:yizhandaodigreen")
	end

	if self.m_status == 3 then
		YiZhanDaoDiAnswerDlg.DestroyDialog()
	end
end

function YiZhanDaoDiAnswerDlg:HandleBtnClicked(args)
	if self.m_status == 2 then
		GetGameUIManager():AddMessageTipById(145736)
	end
	local e = CEGUI.toWindowEventArgs(args)
	local id = e.window:getID()
	if self.m_changeEnable == false then
		return
	end
	if     self.m_answer == 1 then
		self.m_pBtnAEffect:setVisible(false)
	elseif self.m_answer == 2 then
		self.m_pBtnBEffect:setVisible(false)
	elseif self.m_answer == 3 then
		self.m_pBtnCEffect:setVisible(false)
	elseif self.m_answer == 4 then
		self.m_pBtnDEffect:setVisible(false)
	end
	self.m_answer = id
	if     self.m_answer == 1 then
		self.m_pBtnAEffect:setVisible(true)
	elseif self.m_answer == 2 then
		self.m_pBtnBEffect:setVisible(true)
	elseif self.m_answer == 3 then
		self.m_pBtnCEffect:setVisible(true)
	elseif self.m_answer == 4 then
		self.m_pBtnDEffect:setVisible(true)
	end
	-- print("YiZhanDaoDiAnswerDlg:HandleBtnClicked .. " .. self.m_answer)
end

function YiZhanDaoDiAnswerDlg:HandleWindowUpdate(args)
	if GetScene():GetMapID() ~= 1569 then
		YiZhanDaoDiAnswerDlg.DestroyDialog()
		return
	end
	local time = CEGUI.toUpdateEventArgs(args).d_timeSinceLastFrame
	local t1 = math.floor(self.m_time)
	self.m_time = self.m_time + time
	local t2 = math.floor(self.m_time)
	if t1 == t2 then
		return
	end
	if 20-t2 > 10 then
		self.m_pNextTime:setText(tostring(20-t2-10))
	else
		self.m_pNextTime:setText(tostring(20-t2))
	end
	-- 长时间没有收到题，判断为掉线，再发一次拉人协议
	if t1 > 30 then
		local CAgreeDrawRole = require "protocoldef.knight.gsp.faction.cagreedrawrole"
		local req = CAgreeDrawRole.Create()
		req.agree = 1
		req.flag = 5
		LuaProtocolManager.getInstance():send(req)
	end
	-- 0秒 1秒 不用发请求
	if t2 == 0 or t2 == 1 then
		return
	end
	-- 10秒 锁住答案
	if self.m_changeEnable == true and math.floor(self.m_time) == 10 then
		self.m_changeEnable = false
		if     self.m_answer == 1 then
			self.m_pBtnAEffect:setVisible(true)
		elseif self.m_answer == 2 then
			self.m_pBtnBEffect:setVisible(true)
		elseif self.m_answer == 3 then
			self.m_pBtnCEffect:setVisible(true)
		elseif self.m_answer == 4 then
			self.m_pBtnDEffect:setVisible(true)
		end
		self.m_pNextText:setText(MHSD_UTILS.get_resstring(3054))
	end
	-- 12秒后不再发请求
	if self.m_time >= 12 then
		return
	end
--[[
	-- 奇数秒请求选中结果 偶数秒发答案
	if math.fmod(math.floor(self.m_time), 2) == 1 then
		local CResultPreview = require "protocoldef.knight.gsp.activity.yzdd.cresultpreview"
		local req = CResultPreview.Create()
		LuaProtocolManager.getInstance():send(req)
	else
		if self.m_status == 2 then
			local CResultPreview = require "protocoldef.knight.gsp.activity.yzdd.cresultpreview"
			local req = CResultPreview.Create()
			LuaProtocolManager.getInstance():send(req)
		else
			local CAnswer = require "protocoldef.knight.gsp.activity.yzdd.canswer"
			local req = CAnswer.Create()
			req.question = self.m_qid
			req.answer = self.m_answer
			LuaProtocolManager.getInstance():send(req)
		end
	end
]]
	-- 偶数秒发答案
	if math.fmod(math.floor(self.m_time), 2) == 0 and self.m_status == 1 then
		local CAnswer = require "protocoldef.knight.gsp.activity.yzdd.canswer"
		local req = CAnswer.Create()
		req.question = self.m_qid
		req.answer = self.m_answer
		LuaProtocolManager.getInstance():send(req)
	end
	local CResultPreview = require "protocoldef.knight.gsp.activity.yzdd.cresultpreview"
	local req = CResultPreview.Create()
	LuaProtocolManager.getInstance():send(req)
end

return YiZhanDaoDiAnswerDlg
