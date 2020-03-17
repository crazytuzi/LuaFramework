--[[
	新天神
	天神升级
]]

_G.UINewTianshenLvUp = BaseUI:new('UINewTianshenLvUp');
UINewTianshenLvUp.selectIndex = nil;
UINewTianshenLvUp.tianShenVo = nil;
UINewTianshenLvUp.tianShenDefaultMaxStar = 10;  --天神最大星级
UINewTianshenLvUp.tianShenProNum  = 7;          --天神基础属性七条
UINewTianshenLvUp.tianShenDefaultCost = 1;      --天神默认消耗数量为1
UINewTianshenLvUp.itemId = nil;                 --天神升级消耗的物品Id
UINewTianshenLvUp.isAutoStating = false;        --天神是否正在升级中
function UINewTianshenLvUp:Create()
	self:AddSWF('tianshenLvUp.swf',true);
end

function UINewTianshenLvUp:OnLoaded(objSwf)
	objSwf.btnClose.click     = function() self:OnClose() end  
	objSwf.btn_LvStar.click   = function() self:OnBtnLvClick(); end  
	objSwf.btn_autoStar.click = function() self:OnBtnAutoLvClick(); end  
	objSwf.tfNeedItem.rollOver = function(e) self:OnNeedItemOver(e) end
	objSwf.tfNeedItem.rollOut = function(e) TipsManager:Hide() end

	objSwf.btnRules.rollOver =  function() TipsManager:ShowBtnTips(StrConfig["newtianshen205"],TipsConsts.Dir_RightDown); end
	objSwf.btnRules.rollOut = function(e) TipsManager:Hide(); end
end

function UINewTianshenLvUp:OnShow()
	if not self.args or not self.args[1] then
		self:Hide()
		return
	end
	self.selectIndex = self.args[1]
	self.tianShenVo  = NewTianshenModel:GetTianshenByFightSize(self.selectIndex)
	self:InintMaxStar()
	self:UpdateData()
end

function UINewTianshenLvUp:OnNeedItemOver(e)
	TipsManager:ShowItemTips(self.itemId);
end

function UINewTianshenLvUp:UpdateData( )
	if not self.tianShenVo then 
		Debug("not find tianshen object......")
		return 
	end
	self:ShowStar()
	self:ShowPro()
	self:ShowCurLvAndCurFight()
	self:SetSiGrowValue()
	self:CostItemAndHave()
end

-- 初始化最大星级
function UINewTianshenLvUp:InintMaxStar( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local tianShenMaxStar = self.tianShenVo:GetMaxStar()
	local starPanel = objSwf.star
	for i=1,self.tianShenDefaultMaxStar do
		if i > tianShenMaxStar then
			starPanel["graystar"..i]._visible = false
			starPanel["star"..i]._visible = false
		end
	end
end

-- 显示天神星级
function UINewTianshenLvUp:ShowStar( )
	local objSwf = self.objSwf
	if not objSwf then return end
	NewTianshenUtil:SetTianshenSlot(objSwf.fight, self.tianShenVo)
	objSwf.fight.itemBtn.rollOver = function(e)
		TipsManager:ShowNewTianshenTips(self.tianShenVo)
	end
	objSwf.fight.itemBtn.rollOut = function(e)
		TipsManager:Hide()
	end
	local tianShenStar = self.tianShenVo:GetStar()
	local starPanel = objSwf.star
	for i=1,self.tianShenVo:GetMaxStar() do
		if i <= self.tianShenVo:GetStar() then
			starPanel["star"..i]._visible     = true
			starPanel["graystar"..i]._visible = false
		else
			starPanel["star"..i]._visible = false
			starPanel["graystar"..i]._visible = true
		end
	end
end

-- 天神属性
function UINewTianshenLvUp:ShowPro( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local proList = self.tianShenVo:GetPro()
	local nextProList = self.tianShenVo:GetNextLvPro()

	local slot = {}
	local slot1 = {}
	for i=1, 7 do
		table.insert(slot, objSwf["curPro"..i])
		table.insert(slot1, objSwf["nextPro"..i])
	end
	PublicUtil:ShowProInfoForUI(proList, slot, nil, nil, nil, true,nil,"#FFFFFF")
	PublicUtil:ShowProInfoForUI(nextProList, slot1, nil, nil, nil, true,nil,"#FFFFFF")
end

-- 等级属性
function UINewTianshenLvUp:ShowCurLvAndCurFight(  )
	local objSwf = self.objSwf
	if not objSwf then return end
	local curLv,nextLv       = self.tianShenVo:GetLv(),self.tianShenVo:GetLv() + 1
	self.curLv = curLv
	local curfight,nextFight = self.tianShenVo:GetFightValue(), self.tianShenVo:GetNextLvFight()
	objSwf.curLv.htmlText    = curLv
	objSwf.nextLv.htmlText   = nextLv
	objSwf.curfight.htmlText = curfight
	objSwf.nextfight.htmlText= nextFight
end

-- 设置进度条
function UINewTianshenLvUp:SetSiGrowValue( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local curExp = self.tianShenVo:GetLvProgress()
	local maxExp = self.tianShenVo:GetLvNeedCount()
	objSwf.siGrowValue:setProgress(curExp, maxExp )
	objSwf.proText.htmlText = string.format(StrConfig["newtianshen12"],curExp,maxExp)
end

-- 升级消耗
function UINewTianshenLvUp:CostItemAndHave( )
	local objSwf = self.objSwf
	if not objSwf then return end
	local cfg = t_consts[348]
	if not cfg then
		Debug("not find cfg in t_consts line 348......")
		return
	end
	self.itemId = cfg.val1
	local itemCfg = t_item[self.itemId]
	if not itemCfg then
		Debug("not find itemCfgData in t_item:",self.itemId)
		return
	end
	local has = BagModel:GetItemNumInBag(self.itemId);
	local color = has < 1 and "#FF0000" or "#00FF00";
	local color1 = TipsConsts:GetItemQualityColor(itemCfg.quality)
	objSwf.tfNeedItem.htmlLabel = string.format( StrConfig['smithing030'], color1, itemCfg.name, color, 1, has);
end

--手动升级
function UINewTianshenLvUp:OnBtnLvClick( )
	if not self.tianShenVo then
		return
	end
	if not self.tianShenVo:IsCanLvUp() then
		FloatManager:AddNormal(StrConfig['newtianshen115'])
		return
	end
	if BagModel:GetItemNumInBag(self.itemId) < self.tianShenDefaultCost then
		FloatManager:AddNormal(StrConfig["newtianshen100"])
		return
	end
	local id  = self.tianShenVo:GetId()
	NewTianshenController:AskLvUp(id, 0)
end

-- 自动升级
function UINewTianshenLvUp:OnBtnAutoLvClick( )
	if not self.tianShenVo then
		return
	end
	if not self.tianShenVo:IsCanLvUp() then
		FloatManager:AddNormal(StrConfig['newtianshen115'])
		return
	end
	if BagModel:GetItemNumInBag(self.itemId) < self.tianShenDefaultCost then
		FloatManager:AddNormal(StrConfig["newtianshen100"])
		return
	end
	local id  = self.tianShenVo:GetId()
	NewTianshenController:AskLvUp(id, 1)
end

-- 改变按钮状态
function UINewTianshenLvUp:ChangeBtnLabel(state)
	local objSwf = self.objSwf
	if not objSwf then return end
	local autoBtn = objSwf.btn_autoStar
	if state == 0 then
		autoBtn.label = UIStrConfig['newtianshen22'];
	else
		autoBtn.label = UIStrConfig['newtianshen11'];
	end
end

function UINewTianshenLvUp:OnClose( )
	self:Hide()
end

function UINewTianshenLvUp:OnHide( )
	
end

function UINewTianshenLvUp:ListNotificationInterests()
	return {NotifyConsts.tianShenLvUpUpdata,NotifyConsts.PlayerAttrChange,
			NotifyConsts.BagAdd,NotifyConsts.BagRemove,NotifyConsts.BagUpdate,}
end

function UINewTianshenLvUp:HandleNotification(name,body)
	if name == NotifyConsts.tianShenLvUpUpdata then
		if self.tianShenVo then
			if self.tianShenVo:IsMaxLv() then
				self:Hide()
				return
			else
				if self.curLv ~= self.tianShenVo:GetLv() then
					if self.objSwf then
						self.objSwf.starpfx:gotoAndPlay(2)
					end
				end
			end
		end
		self:UpdateData()
	elseif name == NotifyConsts.PlayerAttrChange then
		if body.type == enAttrType.eaLevel or body.type == enAttrType.eaBindGold then
			self:UpdateData()
		end
	elseif name==NotifyConsts.BagAdd or name==NotifyConsts.BagRemove or name==NotifyConsts.BagUpdate then
		self:CostItemAndHave()
	end
end