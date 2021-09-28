require "ui.contactroledlg"
require "ui.pet.petskillqh"
require "ui.pet.petskilltips"
require "ui.pet.petskilladd"
require "ui.pet.petskilldiscard"
require "ui.pet.petamulettips"
require "ui.pet.petamuletadddlg"
require "ui.battlerewarddlg"
require "ui.team.teammembermenu"
require "ui.chengwei.chengweidlg"
require "ui.activity.activitydlginfocell"
require "ui.spring.springactivityinfodlg"
require "ui.fanfanle.fanfanlerewarddlg"
require "ui.skill.wulintipsdlg"
require "ui.jieyi.jieyipersontipsdlg"
require "ui.jieyi.jieyialltipsdlg"

CheckTipsWnd={}

function CheckTipsWnd.OnLButtonDown()
  LogInfo("CheckTipsWnd.OnLButtonDown")    
  CheckTipsWnd.CheckContactRoleDlg()
  CheckTipsWnd.CheckXiakeTipDlg()
  CheckTipsWnd.CheckPetTipsDlg()
  CheckTipsWnd.CheckBattleRewardDlg()
  CheckTipsWnd.CheckTeamMemberMenu()
  CheckTipsWnd.CheckFactionMemberMenu()
  CheckTipsWnd.CheckChengWeiDlg()
  CheckTipsWnd.CheckZhenfaTipDlg()
  CheckTipsWnd.CheckActivityInfo()
  CheckTipsWnd.CheckNumInputDlg()
  CheckTipsWnd.CheckXiakeXiuxingPointDlg()
  CheckTipsWnd.CheckXiakeXiuxingJingjieTip()
  -- CheckTipsWnd.CheckSpringActivityInfoDlg() --add by wuyao for spring festival activities entrance
  CheckTipsWnd.CheckFanfanleRewardDlg() --add by wuyao for fanfanle
  CheckTipsWnd.CheckWulinTipsDlg() --add by wuyao for wulinmiji
  CheckTipsWnd.CheckNuQiSkillDlg() --add by huangjie for nuqijineng
  CheckTipsWnd.CheckHowToPlayDlg() --add by huangjie for wanfa
  CheckTipsWnd.CheckRewardDlg() --add by huangjie for reward
  CheckTipsWnd.CheckPetSummonDlg() --add by huangjie for petsummon
  CheckTipsWnd.CheckJieyiPersonTipsDlg() --add by kyle
  CheckTipsWnd.CheckJieyiAllTipsDlg() --add by kyle
  CheckTipsWnd.CheckXiakePreviewDlg() --add by tangjian
  CheckTipsWnd.CheckRankZongheDlg()
  CheckTipsWnd.CheckRankXiakeDlg()
  CheckTipsWnd.CheckRankPetDlg()
  CheckTipsWnd.CheckRankLevelDlg()
  CheckTipsWnd.CheckLaohujiTip()
end

function CheckTipsWnd.GetCursorWindow()
	local guiSystem = CEGUI.System:getSingleton();
	local mousePos = CEGUI.MouseCursor:getSingleton():getPosition();

	local pTargetWindow = guiSystem:getTargetWindow(mousePos, false);

	return pTargetWindow;
end
local function check(wnd)
	local pTargetWnd = CheckTipsWnd.GetCursorWindow()
	if wnd == pTargetWnd then return true end
    
    if pTargetWnd then
        return pTargetWnd:isAncestor(wnd)
    else
        return false
    end
end
function CheckTipsWnd.CheckWnd(aPWnd)
	local pTargetWnd = CheckTipsWnd.GetCursorWindow();
	local pWnd = aPWnd.m_pMainFrame;

	if pWnd == pTargetWnd or pTargetWnd == nil then return; end

	local isAncestor = pTargetWnd:isAncestor(pWnd);

	if not isAncestor then
		aPWnd:DestroyDialog();
	end
end

function CheckTipsWnd.CheckWnds(...)
	for i, v in ipairs{...} do
		local dlg = v
		if dlg then
			print("check wnd="..dlg.m_pMainFrame:getName())
			local flag = check(dlg.m_pMainFrame)
			if flag then
				return
			end
		end
	end
	for i, v in ipairs{...} do
		if v then
			v:DestroyDialog()
		end
	end
end

function CheckTipsWnd.CheckPetTipsDlg()
	if PetSkillQh.getSingleton() then
		CheckTipsWnd.CheckWnds(PetSkillQh.getSingleton(), PetSkillAdd.getSingleton())
	else
		CheckTipsWnd.CheckWnds(PetSkillAdd.getSingleton())
	end
	CheckTipsWnd.CheckWnds(PetSkillTips.getSingleton())
	CheckTipsWnd.CheckWnds(PetSkillDiscard.getSingleton())
  if PetAmuletTips.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(PetAmuletTips.getInstanceNotCreate())
  end
  if PetAmuletAddDlg.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(PetAmuletAddDlg.getInstanceNotCreate())
  end
  if require "ui.pet.petdiaowendlg".getInstanceNotCreate() then
    CheckTipsWnd.CheckWnds(require "ui.pet.petdiaowendlg".getInstanceNotCreate())
  end
end

function CheckTipsWnd.CheckZhenfaTipDlg()
	if ZhenFaTip.peekInstance() then
		CheckTipsWnd.CheckWnd(ZhenFaTip.peekInstance());
	end
end

function CheckTipsWnd.CheckFactionMemberMenu()
	local dlg = require "ui.faction.factionmain".getInstanceOrNot()
	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.m_pTips
		if rootwnd == pTargetWnd then return true end
	    if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
	         dlg.m_pTips:setVisible(false)
	    end
	end
	dlg = require "ui.faction.factionaccept".getInstanceOrNot()
	if dlg then
		local pTargetWnd = CheckTipsWnd.GetCursorWindow()
		local rootwnd = dlg.m_pMenu
		if rootwnd == pTargetWnd then return true end
	    if not pTargetWnd or not pTargetWnd:isAncestor(rootwnd) then
	         rootwnd:setVisible(false)
	    end
	end
end

function CheckTipsWnd.CheckXiakeTipDlg()
	local tip = SkillXkTip.peekInstance();
	local qianghua = SkillXkQh.peekInstance();
	local book = SkillBookXq.peekInstance();
	local yuan = YuanXiake.peekInstance(); 
--	local jihua = JinhuaXiake.peekInstance();
	local zhenfa = ZhenfaChooseDlg.getInstanceNotCreate();

	if zhenfa ~= nil then
		CheckTipsWnd.CheckWnd(zhenfa);
	end

	if tip ~= nil then
		CheckTipsWnd.CheckWnd(tip);
	end

	if yuan ~= nil then
		CheckTipsWnd.CheckWnd(yuan);
	end

--	if jihua ~= nil then
--		CheckTipsWnd.CheckWnd(jihua);
--	end

	if qianghua ~= nil then
		if book ~= nil then
			local pTargetWnd = CheckTipsWnd.GetCursorWindow();
			if not ((pTargetWnd == book.m_pMainFrame or pTargetWnd:isAncestor(book.m_pMainFrame)) or (pTargetWnd == qianghua.m_pMainFrame or pTargetWnd:isAncestor(qianghua.m_pMainFrame))) then
				qianghua.DestroyDialog()
				book.DestroyDialog()
			end
			--[[
            if not pTargetWnd then
                CheckTipsWnd.CheckWnd(qianghua);
			elseif not pTargetWnd:isAncestor(book.m_pMainFrame) then
				CheckTipsWnd.CheckWnd(qianghua);
			end
			]]
		else
			CheckTipsWnd.CheckWnd(qianghua);
		end
	end

	if book ~= nil then
		if qianghua ~= nil then
			local pTargetWnd = CheckTipsWnd.GetCursorWindow();
			if not ((pTargetWnd == book.m_pMainFrame or pTargetWnd:isAncestor(book.m_pMainFrame)) or (pTargetWnd == qianghua.m_pMainFrame or pTargetWnd:isAncestor(qianghua.m_pMainFrame))) then
				qianghua.DestroyDialog()
				book.DestroyDialog()
			end
			--[[
            if not pTargetWnd then
                CheckTipsWnd.CheckWnd(book);
            elseif not pTargetWnd:isAncestor(qianghua.m_pMainFrame) then
				CheckTipsWnd.CheckWnd(book);
			end
			]]
		else
			CheckTipsWnd.CheckWnd(book);
		end
	end
end

function CheckTipsWnd.CheckContactRoleDlg()
   LogInfo("CheckTipsWnd.CheckContactRoleDlg")
   local inst=  ContactRoleDialog.getInstanceNotCreate()   
   if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd=ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
        inst:DestroyDialog()
      end

   end
end

function CheckTipsWnd.CheckBattleRewardDlg()
    print("CheckTipsWnd.CheckBattleRewardDlg")
   local inst=  BattleRewardDlg.getInstanceNotCreate()   
   if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd=ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
        inst:DestroyDialog()
      end

   end
end

function CheckTipsWnd.CheckTeamMemberMenu()
	print("CheckTipsWnd.CheckTeamMemberMenu")
	local inst=  TeamMemberMenu.getInstanceNotCreate()   
	if inst then
		local guiSystem = CEGUI.System:getSingleton()
      	local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      	local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      	local dlgWnd=inst:GetWindow()
      	local bIsDlgWnd=ptTargetWindow == dlgWnd
      
      	if ptTargetWindow then
        	local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
      		if not bIsDlgWnd and not isAncestor then
        		inst:SetVisible(false)
        	end
      	else
        	inst:SetVisible(false)
      	end
   	end
end

function CheckTipsWnd.CheckChengWeiDlg()
    print("____CheckTipsWnd.CheckChengWeiDlg")
    
    local inst = ChengWeiDlg.getInstanceNotCreate()
    if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd = ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
        inst:DestroyDialog()
      end

   end
end

function CheckTipsWnd.CheckActivityInfo()
	LogInfo("CheckTipsWnd check activity info")
    local inst = ActivityDlgInfoCell.getInstanceNotCreate()
    if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd = ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
		inst:DestroyDialog()
	  end
	end
end
function CheckTipsWnd.CheckNumInputDlg()
	LogInfo("CheckTipsWnd CheckNumInputDlg")
    local inst = NumInputDlg.getInstanceNotCreate()
    if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd = ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
		inst:DestroyDialog()
	  end
	end
end



function CheckTipsWnd.CheckXiakeXiuxingPointDlg()
    local inst = require("ui.xiake.pointtip").getInstanceNotCreate()
    if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd = ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
		inst:DestroyDialog()
	  end
	end
end

function CheckTipsWnd.CheckXiakeXiuxingJingjieTip()
    local inst = require("ui.xiake.jingjietip").getInstanceNotCreate()
    if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd = ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
		inst:DestroyDialog()
	  end
	end
end


--add by wuyao for spring festival activities entrance
function  CheckTipsWnd.CheckSpringActivityInfoDlg()
	if CheckSpringActivityInfoDlg.getInstanceNotCreate() then
		CheckTipsWnd.CheckWnd(CheckSpringActivityInfoDlg.getInstanceNotCreate());
	end
end

--add by wuyao for fanfanle
function  CheckTipsWnd.CheckFanfanleRewardDlg()
	LogInfo("CheckTipsWnd FanfanleRewardDlg")
    local inst = FanfanleRewardDlg.getInstanceNotCreate()
    if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd = ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
		inst:DestroyDialog()
	  end
	end
end

--add by wuyao for wulinmiji
function  CheckTipsWnd.CheckWulinTipsDlg()
  LogInfo("CheckTipsWnd WulinTipsDlg")
    local inst = WulinTipsDlg.getInstanceNotCreate()
    if inst then
      local guiSystem = CEGUI.System:getSingleton()
      local mousePos = CEGUI.MouseCursor:getSingleton():getPosition()
      
      local ptTargetWindow = guiSystem:getTargetWindow(mousePos, false)
      local dlgWnd=inst:GetWindow()
      local bIsDlgWnd = ptTargetWindow == dlgWnd
      
      if ptTargetWindow then
        local isAncestor= ptTargetWindow:isAncestor(dlgWnd)
        if not bIsDlgWnd and not isAncestor then
            inst:DestroyDialog()
        end
      else
    inst:DestroyDialog()
    end
  end
end

function  CheckTipsWnd.CheckJieyiPersonTipsDlg()
  LogInfo("CheckTipsWnd CheckJieyiPersonTipsDlg")
	local dlg = require "ui.jieyi.jieyipersontipsdlg"
	if dlg.getInstanceNotCreate() then
		CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
	end
end

function  CheckTipsWnd.CheckJieyiAllTipsDlg()
  LogInfo("CheckTipsWnd CheckJieyiAllTipsDlg")
	local dlg = require "ui.jieyi.jieyialltipsdlg"
	if dlg.getInstanceNotCreate() then
		CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
	end
end

function CheckTipsWnd.CheckNuQiSkillDlg()
	local NuQiJiinNormalDlg = require "ui.skill.nuqijiinnormaldlg"
	local NuQiJiinWuShuangDlg = require "ui.skill.nuqijiinwushuangdlg"
	local NuQiQueRenDlg = require "ui.skill.nuqiquerendlg"
	if NuQiQueRenDlg.getInstanceNotCreate() then
		CheckTipsWnd.CheckWnd(NuQiQueRenDlg.getInstanceNotCreate())
	else
		if NuQiJiinNormalDlg.getInstanceNotCreate() then
			CheckTipsWnd.CheckWnd(NuQiJiinNormalDlg.getInstanceNotCreate())
		end
		if NuQiJiinWuShuangDlg.getInstanceNotCreate() then
			CheckTipsWnd.CheckWnd(NuQiJiinWuShuangDlg.getInstanceNotCreate())
		end
	end
end

function CheckTipsWnd.CheckHowToPlayDlg()
	local HowToPlayDlg = require "ui.tips.howtoplaydlg"
	if HowToPlayDlg:getInstanceOrNot() then
		CheckTipsWnd.CheckWnd(HowToPlayDlg:getInstanceOrNot())
	end
end

function CheckTipsWnd.CheckRewardDlg()
	local RewardDlg = require "ui.xiaganyidan.rewarddlg"
	if RewardDlg:getInstanceOrNot() then
		CheckTipsWnd.CheckWnd(RewardDlg:getInstanceOrNot())
	end
end

function CheckTipsWnd.CheckPetSummonDlg()
	local BattlePetSummonDlg = require "ui.pet.battlepetsummondlg"
	if BattlePetSummonDlg.getInstanceNotCreate() then
		CheckTipsWnd.CheckWnd(BattlePetSummonDlg.getInstanceNotCreate())
	end
end

function CheckTipsWnd.CheckXiakePreviewDlg()
	local XiakePreviewDlg = require "ui.xiake.xiakepreviewdlg"
	if XiakePreviewDlg.getInstanceNotCreate() then
		CheckTipsWnd.CheckWnd(XiakePreviewDlg.getInstanceNotCreate())
	end
end

function CheckTipsWnd.CheckRankZongheDlg()
  local dlg = require "ui.rank.rankzongheviewdlg"
  if dlg.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
  end
end

function CheckTipsWnd.CheckRankXiakeDlg()
  local dlg = require "ui.rank.rankxiakeviewdlg"
  if dlg.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
  end
end

function CheckTipsWnd.CheckRankPetDlg()
  local dlg = require "ui.rank.rankpetviewdlg"
  if dlg.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
  end
end

function CheckTipsWnd.CheckLaohujiTip()
  local dlg = require "ui.laohuji.laohujihelp"
  if dlg.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
  end
  dlg = require "ui.laohuji.laohujirank"
  if dlg.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(dlg.getInstanceNotCreate())
  end
end

function CheckTipsWnd.CheckRankLevelDlg()
  local pTargetWnd = CheckTipsWnd.GetCursorWindow()
  local viewdlg = require "ui.rank.ranklevelviewdlg"
  local tipsdlg = require "ui.tips.tooltipsdlg"

  if viewdlg.getInstanceNotCreate() then
    if not check(viewdlg.getInstanceNotCreate().m_pMainFrame) and not check(tipsdlg.GetTipWindow()) then
      viewdlg.DestroyDialog()
    end
  end
end

function  CheckTipsWnd.CheckJieyiPersonTipsDlg()
  local SDZhaJiTipsDlg = require "ui.sdzhaji.sdzhajitipsdlg"
  if SDZhaJiTipsDlg.getInstanceNotCreate() then
    CheckTipsWnd.CheckWnd(SDZhaJiTipsDlg.getInstanceNotCreate())
  end
end