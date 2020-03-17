--[[
	2015年10月12日, PM 03:37:27
	商业活动主UI
]]

_G.UIMainOperActivites = BaseUI:new('UIMainOperActivites');
UIMainOperActivites.currentIconId = 0
UIMainOperActivites.isShowFirst = false
UIMainOperActivites.isNoTween = false

function UIMainOperActivites:new(name)
	local obj = BaseUI:new(name);
	for i,v in pairs(UIMainOperActivites) do
		if type(v) == "function" then
			obj[i] = v;
		end;
	end; 
	return obj;
end

function UIMainOperActivites:Create()
	self:AddSWF('mainOperactivities.swf',true,'center');
	
	self:CreateChildPanel()
end

function UIMainOperActivites:CreateChildPanel()
	self:AddChild(UIOperactivitesBusiness, "business");						--商业活动(常用的一种)
	self:AddChild(UIOperactivitesExchange, "exchange");						--兑换
	self:AddChild(UIOperactivitesRanking, "rankReward");					--排行榜
	self:AddChild(UIOperactivitesTeamBuy, "teamBuy");						--团购活动
	self:AddChild(UIOperactivitesWangcheng, "cityActivity");				--王城战斗
	self:AddChild(UIOperactivitesShow, "operActshow");						--展示
	self:AddChild(UIOperactivitesTeamBuyFirst, "teamBuyFirst");				--首冲团购活动
	-- self:AddChild(UIOperactivitesAward, "operaward")                        --抽奖
	self:AddChild(UIOperactivitesExchangeSpecial, "exchange1")                        --特殊兑换 元宝购买
	self:AddChild(UIOperactivitesSpecialExchange, "exchange2")				--特殊兑换 4列
	self:AddChild(UIOperavtivitesTwoExchange, "exchange3")					--特殊兑换 2列
	self:AddChild(UIOperavtivitesOneExchange, "exchange4")					--特殊兑换 一堆等级
	self:AddChild(UIOperactivitesVipGet, "opervipaward")					--vip奖励领取
end

function UIMainOperActivites:GetWidth()
	return 1146
end

function UIMainOperActivites:GetHeight()
	return 742
end

function UIMainOperActivites:OnLoaded(objSwf)
	self:GetChild("business"):SetContainer(objSwf.childPanel);			--商业活动(常用的一种)
	self:GetChild("exchange"):SetContainer(objSwf.childPanel);			--兑换
	self:GetChild("rankReward"):SetContainer(objSwf.childPanel);		--排行榜
	self:GetChild("teamBuy"):SetContainer(objSwf.childPanel);			--团购活动
	self:GetChild("cityActivity"):SetContainer(objSwf.childPanel);		--王城战斗
	self:GetChild("operActshow"):SetContainer(objSwf.childPanel);		--展示
	self:GetChild("teamBuyFirst"):SetContainer(objSwf.childPanel);		--首冲团购活动
	-- self:GetChild('operaward'):SetContainer(objSwf.childPanel)			--抽奖
	self:GetChild('exchange1'):SetContainer(objSwf.childPanel)			--特殊兑换傻逼
	self:GetChild('exchange2'):SetContainer(objSwf.childPanel)
	self:GetChild("exchange3"):SetContainer(objSwf.childPanel)			--特殊兑换两列
	self:GetChild("exchange4"):SetContainer(objSwf.childPanel)			--特殊兑换 一堆等级
	self:GetChild('opervipaward'):SetContainer(objSwf.childPanel)		--vip奖励领取
	--
	objSwf.btn_close.click = function() self:OnBtnCloseClick(); end;	
	objSwf.listActGroup.itemClick = function(e) self:OnActGroupClick(e); end
	
	objSwf.btnPre.click = function()
		OperActUIManager.currentPage = OperActUIManager.currentPage - 1			
		self.isShowFirst = true		
		self:InitList()
	end
	objSwf.btnNext.click = function()		
		OperActUIManager.currentPage = OperActUIManager.currentPage + 1		
		self.isShowFirst = true		
		self:InitList()
	end
end

function UIMainOperActivites:WithRes()
	return {"operactivitesBusiness.swf", "operactivitesAward.swf", 
	"operactivitesTeamBuy.swf","operactivitesGetAward.swf","operactivitesExchange.swf",
	"operactivitesTeamBuyFirst.swf", "operactivitesWangcheng.swf",
	"operactivitesExchange1.swf","operactivitesExchangeList.swf","operactivitesTwoEchange.swf",
	"operactivitesSpecialEchange.swf", "operactivitesRankReward.swf"};
end

function UIMainOperActivites:InitList()
	local objSwf = self.objSwf
	if not objSwf then return end
	
	local itemList, firstGroupId = OperActUIManager:GetTabList(self.currentIconId)
	self:UpdateItemList(itemList)
	
	if firstGroupId and self.isShowFirst then	
		self.isShowFirst = false
		OperActUIManager:ShowChildUI(firstGroupId, true)
		objSwf.listActGroup.selectedIndex = 0
	end
	
	self:UpdateBtnState()
end

function UIMainOperActivites:UpdateItemList(itemList)
	local objSwf = self.objSwf
	if not objSwf then return end
	-- print(debug.traceback())
	-- debug.debug()
	objSwf.listActGroup.dataProvider:cleanUp();	
	if not itemList then
		itemList = OperActUIManager:GetTabList(self.currentIconId)	
	end
	if itemList and #itemList > 0 then
		objSwf.listActGroup.dataProvider:push(unpack(itemList));
	end
	objSwf.listActGroup:invalidateData();
end

function UIMainOperActivites:OnActGroupClick(e)
	local data = e.item;
	local group = data.group;
	if not group then return; end
	-- FPrint('打开运营活动id'..group)
	OperActUIManager:ShowChildUI(group)	
end

function UIMainOperActivites:TurnToChild(childName)
	local childUI = self:GetChild(childName)
	if childUI and childUI:IsShow() then
		childUI:OnShow()
	else
		self:ShowChild(childName)
	end
end

function UIMainOperActivites:OnShow()	
	local objSwf = self.objSwf
	if not objSwf then return end

	if self.args and self.args[1] then
		self.currentIconId = self.args[1]	
	end
	
	OperactivitiesModel.isClickIconList[self.currentIconId] = true
	Notifier:sendNotification(NotifyConsts.UpdateOperActBtnIconState);
	
	OperActUIManager.currentPage = 1
	self.isShowFirst = true
	OperactivitiesController:ReqPartyList(self.currentIconId)
	
	local btnStateVO = OperactivitiesModel:GetOperBtnState(self.currentIconId)	
	local urlStr = ""
	if btnStateVO.imageTxt and btnStateVO.imageTxt ~= "" then
		urlStr = ResUtil:GetOperActivityNameIcon(btnStateVO.imageTxt.."_3")
	else
		if self.currentIconId == OperactivitiesConsts.iconHuodong1 then
			 ResUtil:GetOperActivityNameIcon("opername4_3")
		elseif self.currentIconId == OperactivitiesConsts.iconHuodong2 then
			ResUtil:GetOperActivityNameIcon("opername3_3")
		elseif self.currentIconId == OperactivitiesConsts.iconHuodong3 then
			ResUtil:GetOperActivityNameIcon("opername3_3")
		elseif self.currentIconId == OperactivitiesConsts.iconHuodong4 then
			ResUtil:GetOperActivityNameIcon("opername3_3")
		end	
	end	
	
	if urlStr and urlStr ~= "" then
		if urlStr ~= objSwf.titleLoader.source then
			objSwf.titleLoader.source = urlStr
		end
	else
		objSwf.titleLoader:unload()
	end
end

function UIMainOperActivites:IsTween()
	return true
end

function UIMainOperActivites:GetPanelType()
	return 1
end

function UIMainOperActivites:IsShowSound()
	return true
end


--点击关闭按钮
function UIMainOperActivites:OnBtnCloseClick()
	self:Hide();
end

function UIMainOperActivites:ListNotificationInterests()
	return {
		NotifyConsts.OperActivityInitInfo,
		NotifyConsts.UpdateOperActAwardState,
		NotifyConsts.OperActivityInitState,
		NotifyConsts.UpdateGroupItemList,
		NotifyConsts.OpenChildPanelByGroupId,
	}
end

function UIMainOperActivites:HandleNotification( name, body )
	if not self:IsShow() then
		return
	end

	if name == NotifyConsts.OperActivityInitInfo then
		if body.btn == self.currentIconId then
			OperactivitiesController:ReqPartyStatList(self.currentIconId)
		end
	elseif name == NotifyConsts.UpdateOperActAwardState then
		self:InitList()
	elseif name == NotifyConsts.OperActivityInitState then	
		-- OperActUIManager.currentPage = 1		
		self:InitList()
	elseif name == NotifyConsts.UpdateGroupItemList then
		-- if body and body.isShowFirst then
			-- OperActUIManager.currentPage = 1	
			-- self.isShowFirst = true
			-- self:InitList()
		-- else
			self:UpdateItemList()		
		-- end
	elseif name == NotifyConsts.OpenChildPanelByGroupId then
		self:TurnToChild(body.childName)
	end	
end

function UIMainOperActivites:UpdateBtnState()
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.btnNext.disabled = false
	objSwf.btnPre.disabled = false
	if OperActUIManager.currentPage <= 1 then
		objSwf.btnPre.disabled = true
	end
	local maxPage = math.ceil(OperActUIManager:GetItemNum()/OperActUIManager.ShowNum)
	if OperActUIManager.currentPage >= maxPage then
		objSwf.btnNext.disabled = true
	end	
	
	objSwf.textField.text = OperActUIManager.currentPage ..'/'.. maxPage
end

--执行缓动
function UIMainOperActivites:DoTweenHide()
	if self.isNoTween then
		self:DoHide()
		self.isNoTween = false
		return
	end

	local endX,endY;
	if self.tweenStartPos then
		endX = self.tweenStartPos.x;
		endY = self.tweenStartPos.y;
	else
		local winW,winH = UIManager:GetWinSize();
		endX = winW/2;
		endY = winH;
	end
	--
	if not self.swfCfg then
		self:DoHide()
		return
	end
	if not self.swfCfg.objSwf then
		self:DoHide()
		return
	end
	local mc = self.swfCfg.objSwf.content;			
	Tween:To(mc,0.45,{_alpha=0,_width=20,_height=20,_x=endX,_y=endY},
				{onComplete=function()
					self:DoHide();
					mc._xscale = 100;
					mc._yscale = 100;
					mc._alpha = 100;
				end},true);
end
