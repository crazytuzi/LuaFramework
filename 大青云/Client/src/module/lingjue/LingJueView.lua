--[[
灵诀 view
haohu
2016年1月22日11:33:33
]]

_G.UILingJue = BaseUI:new("UILingJue")

UILingJue.GROUP_NUM_IN_ONE_PAGE = 3

function UILingJue:Create()
	self:AddSWF("lingjue.swf", true, 'center')
end

function UILingJue:OnLoaded( objSwf )
	objSwf.btnClose.click = function() self:Hide() end
	objSwf.list.itemBtnClick = function(e) self:OnCanWuClick(e) end
	objSwf.list.itemBtnRollOver = function(e) self:OnCanWuRollOver(e) end
	objSwf.list.itemBtnRollOut = function(e) TipsManager:Hide() end
	objSwf.list.itemPromptRollOver = function(e) self:OnItemPromptRollOver(e) end
	objSwf.list.itemPromptRollOut = function() TipsManager:Hide() end

	objSwf.list.itemConsumeRollOver = function(e) self:OnConsumeRollOver(e) end
	objSwf.list.itemConsumeRollOut = function() TipsManager:Hide() end
	objSwf.list.itemItemRollOver = function(e) self:OnItemRollOver(e) end
	objSwf.list.itemItemRollOut = function() TipsManager:Hide() end
	objSwf.btnAttrTotal.rollOver = function() self:OnBtnAttrRollOver() end
	objSwf.btnAttrTotal.rollOut = function() TipsManager:Hide() end
	objSwf.lblPrompt.htmlText = StrConfig['lingjue15']
	objSwf.btnAttrTotal.htmlLabel = StrConfig['lingjue16']
	self:InitPageStepper(objSwf)
end

function UILingJue:InitPageStepper(objSwf)
	local maxPage = toint( LingJueModel:GetGroupNum() / UILingJue.GROUP_NUM_IN_ONE_PAGE, 1 )
	objSwf.ns.maximum = maxPage
	objSwf.ns.minimum = 1
	objSwf.ns.change = function() self:OnPageChange() end
end

function UILingJue:OnShow()
	self:ShowList()
	self:ShowPage()
end

function UILingJue:ShowPage()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.ns.value = objSwf.ns.minimum
end

function UILingJue:ShowList()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.list.dataProvider:cleanUp()
	local groups = LingJueModel:GetSortedLingJueGroups()
	for _, group in ipairs(groups) do
		objSwf.list.dataProvider:push( group:GetUIData() )
	end
	objSwf.list:invalidateData()
end

function UILingJue:OnCanWuClick(e)
	local tid = e.item and e.item.tid
	LingJueController:ReqLingJueLevelUp( tid )
end

function UILingJue:OnCanWuRollOver(e)
	local tid = e.item and e.item.tid
	local lingJue = LingJueModel:GetLingJue(tid)
	if lingJue then
		lingJue:ShowBtnTips()
	end
end

function UILingJue:OnItemPromptRollOver(e)
	local groupId = e.item and e.item.groupId
	local group = LingJueModel:GetGroup(groupId)
	if group then
		group:ShowPromptTips()
	end
end

function UILingJue:OnConsumeRollOver(e)
	local tid = e.item and e.item.tid
	local lingJue = LingJueModel:GetLingJue(tid)
	if lingJue then
		lingJue:ShowConsumeTips()
	end
end

function UILingJue:OnItemRollOver(e)
	local tid = e.item and e.item.tid
	local lingJue = LingJueModel:GetLingJue(tid)
	if lingJue then
		lingJue:ShowTips()
	end
end

function UILingJue:OnBtnAttrRollOver()
	local tips = StrConfig['lingjue17']
	local attr = LingJueModel:GetAttrTotal()
	for _, vo in ipairs(attr) do
		tips = tips .. string.format( "<br/><font color='#D5B772'>%s</font><font color='#00FF00'> +%s</font>", enAttrTypeName[ vo.type ], vo.val )
	end
	TipsManager:ShowBtnTips(tips, TipsConsts.Dir_RightDown)
end

function UILingJue:OnPageChange()
	local objSwf = self.objSwf
	if not objSwf then return end
	local list = objSwf.list
	local ns = objSwf.ns
	list:scrollToIndex( (ns.value * UILingJue.GROUP_NUM_IN_ONE_PAGE) - 1 )
end

function UILingJue:ListNotificationInterests()
	return {
		NotifyConsts.LingJuePro,
		NotifyConsts.BagItemNumChange,
	}
end

function UILingJue:HandleNotification(name, body)
	if name == NotifyConsts.LingJuePro then
		self:ShowList()
	elseif name == NotifyConsts.BagItemNumChange then
		self:ShowList()
	end
end

-- 是否缓动
function UILingJue:IsTween()
	return true
end

--面板类型
function UILingJue:GetPanelType()
	return 1
end

--是否播放开启音效
function UILingJue:IsShowSound()
	return true
end

function UILingJue:IsShowLoading()
	return true
end

