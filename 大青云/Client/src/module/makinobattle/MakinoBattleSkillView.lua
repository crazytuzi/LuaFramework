--[[
	时间:  2016年10月22日 14:01:25
	开发者:houxudong
	功能:  牧野之战技能界面
]]

_G.UIMakinobattleSkillView = BaseUI:new('UIMakinobattleSkillView');

UIMakinobattleSkillView.skillIdList = {};    --技能id列表
UIMakinobattleSkillView.energyList  = {};    --技能对应能量列表
UIMakinobattleSkillView.skillList   = {};    --技能列表

function UIMakinobattleSkillView:Create()
	self:AddSWF("makinobattleSkill.swf",true,"bottom");
end

function UIMakinobattleSkillView:OnLoaded( objSwf )
	objSwf.skillPanel.skillList.itemClick    = function(e) self:OnSkillItemClick(e); end
	objSwf.skillPanel.skillList.itemRollOver = function(e) self:OnSkillItemOver(e); end
	objSwf.skillPanel.skillList.itemRollOut  = function(e) self:OnSkillItemOut(e); end
end

function UIMakinobattleSkillView:OnShow()
	self:InitSkillPanel()
	self:InitSkill()
	self:InitSkillList()
end

-- 初始化技能列表
function UIMakinobattleSkillView:InitSkillList( )
	local objSwf = self.objSwf
	if not objSwf then return end
	self.skillList = self:GetMainPageSkillList();
	objSwf.skillPanel.skillList.dataProvider:cleanUp();
	for i,slotVO in ipairs(self.skillList) do
		objSwf.skillPanel.skillList.dataProvider:push(slotVO:GetUIData(true));
	end
	objSwf.skillPanel.skillList:invalidateData();
end

-- 得到技能数据
function UIMakinobattleSkillView:GetMainPageSkillList()
	local list = {};
	local curEnergy = MakinoBattleDungeonModel:GetCurAllPointSocre(); --当前的技能总积分
	for i=1,4 do
		local slotVO = SkillSlotVO:new();
		slotVO.pos = i;                                           --技能位置
		if self.skillIdList[i] and self.skillIdList[i].skillId > 0 then
			slotVO.hasSkill = true;                               --改技能条件是否满足
			slotVO:SetSkillId(self.skillIdList[i].skillId);       --技能id
			slotVO.consumEnough = SkillController:CheckConsume(self.skillIdList[i].skillId)==1;    --消耗能量
		else
			slotVO.hasSkill = false;
		end
		slotVO.hideSet = true                                     --隐藏设置
		table.push(list,slotVO);
	end
	return list;
end

--播放技能CD
function UIMakinobattleSkillView:SkillPlayCD(skillId,time)
	local objSwf = self.objSwf;
	if not objSwf then return; end
	for k,vo in pairs(self.skillIdList) do
		if vo.skillId == skillId then 
			local item = objSwf.skillPanel.skillList:getRendererAt(vo.pos - 1);  --从0开始的，需要减1
			if not item then return; end
			item:playCD(time);
			return;
		end
	end
end

--处理消息
function UIMakinobattleSkillView:HandleNotification(name, body)
	if name == NotifyConsts.PlayerAttrChange then
		if name == NotifyConsts.SkillPlayCD then
			self:SkillPlayCD(body.skillId,body.time);
		end
	end
end

function UIMakinobattleSkillView:ListNotificationInterests()
	return {
		NotifyConsts.PlayerAttrChange,
		NotifyConsts.SkillPlayCD,
		};
end

function UIMakinobattleSkillView:OnSkillItemOut(e )
	TipsManager:Hide();
end

function UIMakinobattleSkillView:OnSkillItemOver(e )
	if not e.item.hasSkill  then return; end
	local tipsType = TipsConsts.Type_Skill;
	local tipsShowType = TipsConsts.ShowType_Normal;
	local tipsDir = TipsConsts.Dir_RightUp;
	local tipsInfo = { skillId = e.item.skillId };
	TipsManager:ShowTips( tipsType, tipsInfo, tipsShowType, tipsDir );
end

-- 点击释放技能
function UIMakinobattleSkillView:OnSkillItemClick(e)
	if not e.item.hasSkill then return; end
	local config = t_skill[e.item.skillId];
	if not config then
		return;
	end
	SkillController:PlayCastSkill(e.item.skillId)
end

-- 初始化技能界面
function UIMakinobattleSkillView:InitSkill( )
	local objSwf = self.objSwf
	if not objSwf then return end
	for i=1,4 do
		local cfg = t_muyeskill[i]
		if not cfg then return; end
		local vo = {}
		local skillId = cfg.skill
		local skillcfg  = t_skill[skillId]
		if not skillcfg then return; end
		vo.energy = toint(skillcfg.consum_num)
		table.push(self.energyList,vo)
		local v = {}
		v.pos = i
		v.skillId = skillId
		table.push(self.skillIdList,v)
	end
	local textField;
	for i=1,4 do
		textField = objSwf.skillPanel["energy"..i]
		textField.htmlText = string.format(StrConfig['makinoBattle90001'],self.energyList[i].energy)
	end
end

-- 更新技能能量点数
function UIMakinobattleSkillView:UpdateSkillInfo(num)
	local objSwf = self.objSwf
	if not objSwf then return end
	objSwf.skillPanel.totalEnergy.htmlText = num
	self:InitSkillList()
end

-- 初始化技能界面的位置
function UIMakinobattleSkillView:InitSkillPanel( )
	local objSwf = self.objSwf
	if not objSwf then return; end
	local wWidth,wHeight = UIManager:GetWinSize(); 
	objSwf.skillPanel._y = wHeight / 6
	objSwf.skillPanel._visible = true
end

-- 调整技能界面的位置
function UIMakinobattleSkillView:OnResize(dwWidth,dwHeight)
	self:InitSkillPanel()
end 

function UIMakinobattleSkillView:OnHide()
	local objSwf = self.objSwf;
	if not objSwf then return end
	objSwf.skillPanel._visible = false
	objSwf.skillPanel.skillList.dataProvider:cleanUp();
end
