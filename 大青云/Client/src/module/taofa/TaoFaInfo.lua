--[[
讨伐任务信息面板
houxudong
2016年10月7日19:44:25
--]]
_G.UITaoFaInfo = BaseUI:new("UITaoFaInfo")

function UITaoFaInfo:Create()
	self:AddSWF("taofaInfo.swf",true,"center")
end

function UITaoFaInfo:OnLoaded(objSwf, name)
	objSwf.panel.btnBack.click = function() self:OnBtnBackClick() end
	objSwf.panel.rewardlist.itemRollOver = function (e) TipsManager:ShowItemTips(e.item.id); end
	objSwf.panel.rewardlist.itemRollOut = function () TipsManager:Hide(); end
	objSwf.panel.btnOpen.click = function() self:OnBtnOpenClick(e) end
	objSwf.btnCloseState.click = function() self:OnBtnCloseClick() end
	objSwf.btnCloseState._visible = false
end

function UITaoFaInfo:OnShow( )
	self:ShowReward();
end

-- 显示奖励
function UITaoFaInfo:ShowReward( )
	local objSwf = self.objSwf
	if not objSwf then return end
	if TaoFaModel.curTaskID ==0 then return; end
	local cfg = t_taofa[TaoFaModel.curTaskID];
	if not cfg then return end
	local rewardItemList = RewardManager:Parse( cfg.reward );
	objSwf.panel.rewardlist.dataProvider:cleanUp();
	objSwf.panel.rewardlist.dataProvider:push( unpack(rewardItemList) );
	objSwf.panel.rewardlist:invalidateData();
end

-- 初始化信息
function UITaoFaInfo:InitInfo(type,num)
	local objSwf = self.objSwf
	if not objSwf then return end
	local bossId,bossTotalNum,monsterId,monsterTotalNum = TaoFaModel:GetDungeonInfo()
	local bossCfg = t_monster[bossId]
	local monsterCfg = t_monster[monsterId]
	local bossName = ""
	local monsterName = ""
	if not bossCfg then
		bossName = StrConfig["dungeon905"]
	else
		bossName = bossCfg.name
	end
	if not monsterCfg then
		monsterName = StrConfig["dungeon905"]
	else
		monsterName = monsterCfg.name
	end

	local bossKill = "";
	local monsterKill = "";
	if type == 1 then
		bossKill = "("..num.."/"..bossTotalNum..")";
		if not bossCfg then
			bossKill = ""
		end
		objSwf.panel.txtBOSS.htmlText ="<u>"  .. bossName .. "</u>".."<font color='#ffffff'>"..bossKill.."</font>";
	elseif type == 2 then
		monsterKill = "("..num.."/"..monsterTotalNum..")"
		if not monsterCfg then
			monsterKill = ""
		end
		objSwf.panel.txtMonster.htmlText ="<u>"  .. monsterName .. "</u>".."<font color='#ffffff'>"..monsterKill.."</font>";
	elseif type == 0 then   --初始化信息
		bossKill = "("..num.."/"..bossTotalNum..")";
		monsterKill = "("..num.."/"..monsterTotalNum..")"
		if not bossCfg then
			bossKill = ""
		end
		if not monsterCfg then
			monsterKill = ""
		end
		objSwf.panel.labName.htmlText = "<u>"  .. StrConfig["dungeon904"] .. "</u>"
		objSwf.panel.txtBOSS.htmlText ="<u>"  .. bossName .. "</u>".."<font color='#ffffff'>"..bossKill.."</font>";
		objSwf.panel.txtMonster.htmlText ="<u>"  .. monsterName .. "</u>".."<font color='#ffffff'>"..monsterKill.."</font>";
	end
	
end

-- 刷新信息
function UITaoFaInfo:UpdateInfo(type,num)
	self:InitInfo(type,num)
end

function UITaoFaInfo:OnBtnBackClick( )
	local content = StrConfig["dungeon901"];
	local confirmFunc = function() self:QuitDungeon(); end
	local confirmLabel = StrConfig["dungeon902"];
	local cancelLabel  = StrConfig["dungeon903"];
	self.quitConfirm = UIConfirm:Open( content, confirmFunc, nil, confirmLabel, cancelLabel );
end

-- 退出副本
function UITaoFaInfo:QuitDungeon()
	TaoFaController:ReqQuitDungeon( )
end

function UITaoFaInfo:GetWidth(szName)
	return 378 
end

function UITaoFaInfo:GetHeight(szName)
	return 325
end

--点击展开按钮
function UITaoFaInfo:OnBtnOpenClick(e)
	local objSwf = self:GetSWF("UITaoFaInfo")
	if not objSwf then return end
	objSwf.panel._visible = false
	objSwf.btnCloseState._visible = true
end

--点击展开按钮
function UITaoFaInfo:OnBtnCloseClick()
	local objSwf = self:GetSWF("UITaoFaInfo")
	if not objSwf then return end
	objSwf.panel._visible = true;
	objSwf.btnCloseState._visible = false;
end