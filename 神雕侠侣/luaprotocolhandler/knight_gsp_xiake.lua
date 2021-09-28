
local sreqxiayivalue = require "protocoldef.knight.gsp.xiake.sreqxiayivalue"
function sreqxiayivalue:process()
	LogInfo("sreqxiayivalue process")
	require "ui.xiake.qiyu_xiake"
	XiakeQiyu.RefreshXiaYiValue(self.xiayi)
end

local sreleasexiake = require "protocoldef.knight.gsp.xiake.sreleasexiake"

function sreleasexiake:process()
	LogInfo("____sreleasexiake:process")
	require "ui.xiake.qiyu_xiake"
    
    --show xiake qiansan, get xiake xiayi info
    local strbuilder = StringBuilder:new()
    local strMsg = ""
    
    --[[
    if #(self.xiakelist) == #(self.xiakexiayilist) then
       local numReleased = #(self.xiakelist)
       print("____numReleased: " .. numReleased)
       for i = 1, numReleased, 1 do
            local xiakeReg = XiakeMng.GetXiakeFromKey(self.xiakelist[i])
            if xiakeReg then
                local xiakexyReg = self.xiakexiayilist[i]
                local xk = XiakeMng.ReadXiakeData(xiakeReg.xiakeid)
                local xkname = xk.xkxx.name
                
                print("____self.xiakelist[i]: " .. self.xiakelist[i])
                print("____xkname: " .. xkname)
                print( "____xkcolor: " .. scene_util.GetPetColour(xiakeReg.color) )
                print("____xiakexyReg: " .. xiakexyReg)

                strbuilder:Set("parameter1", xkname)
                strbuilder:Set("parameter2", scene_util.GetPetColour(xiakeReg.color))
                strbuilder:SetNum("parameter3", xiakexyReg)
                strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144975))
                GetGameUIManager():AddMessageTip(strMsg)
            end
       end
    end]]
    
    --Add this part by xiaolong lv for bug 26823
    local xiayiGot = 0
    local numXiayiList = #(self.xiakexiayilist)
    local numXiakeList = #(self.xiakelist)
    if numXiakeList == numXiayiList then
        for i = 1, numXiayiList, 1 do
            xiayiGot = xiayiGot + self.xiakexiayilist[i]
        end
    end
    if xiayiGot > 0 then
        strbuilder:SetNum("parameter1", numXiakeList)
        strbuilder:SetNum("parameter2", xiayiGot)
        strMsg = strbuilder:GetString(MHSD_UTILS.get_msgtipstring(144975))
        GetGameUIManager():AddMessageTip(strMsg)
    end

    strbuilder:delete()

    XiakeMng.RemoveXiakesFromKeyList(self.xiakelist)

    if XiakeQiyu.IsVisible() then
        local qiyu = XiakeQiyu.peekInstance()
        if qiyu then
            qiyu:RefreshQianSanInfo()
        end
    end
end

local sclickxiake10times = require "protocoldef.knight.gsp.xiake.sclickxiake10times"
function sclickxiake10times:process()
	LogInfo("sclickxiake10times process")
	require "ui.xiake.quackfoundrare"
	QuackFoundRare.getInstanceAndShow():InitList(self.xiakelist)
end
 
local sopenchuangong = require "protocoldef.knight.gsp.xiake.sopenchuangong"
function sopenchuangong:process()
    LogInfo("____sopenchuangong:process")
    
    if self.cgtype == 1 then
        local myXiake = MyXiake_xiake.peekInstance()
        if myXiake ~= nil then
            myXiake.m_pMainFrame:setVisible(false)
            local dlgSelfCG = SelfChuanGong.peekInstance()
            if not dlgSelfCG then
                dlgSelfCG = SelfChuanGong.GetAndShow()
            end
            if dlgSelfCG and SelfChuanGong.IsVisible() then
                dlgSelfCG:SetContent(self.xiakekey, self.xiakeprops, self.exp, false)
            end
        end
    elseif self.cgtype == 2 then
        local myXiake = MyXiake_xiake.peekInstance()
        if myXiake ~= nil then
            myXiake.m_pMainFrame:setVisible(false)
            
            local dlgXKCG = XiakeChuanGong.peekInstance()
            if not dlgXKCG then
                dlgXKCG = XiakeChuanGong.GetAndShow()
            end
            if dlgXKCG and XiakeChuanGong.IsVisible() then
                dlgXKCG:RefreshUIFromOpening(self.xiakekey, self.xiakeprops, self.otherxiakes)
            end
        end
    else
        LogInfo("____error self.cgtype")
    end
end

local schuangongresult = require "protocoldef.knight.gsp.xiake.schuangongresult"
function schuangongresult:process()
    LogInfo("____schuangongresult:process")
    
    if self.cgtype == 1 then
        local dlgSelfCG = SelfChuanGong.peekInstance()
        if dlgSelfCG and SelfChuanGong.IsVisible() then
            dlgSelfCG:SetContent(self.xiakekey, self.xiake, self.exp, true)
        end
    elseif self.cgtype == 2 then
        XiakeMng.RemoveXiakesFromKeyList(self.xiakelist)
        local dlgXKCG = XiakeChuanGong.peekInstance()
        if dlgXKCG and XiakeChuanGong.IsVisible() then
            dlgXKCG:RefreshUIFromResult(self.xiakekey, self.xiake, self.xiakelist)
        end
    else
        LogInfo("____error self.cgtype")
    end
end

local sgetxklistchuangongprop = require "protocoldef.knight.gsp.xiake.sgetxklistchuangongprop"
function sgetxklistchuangongprop:process()
    LogInfo("____sgetxklistchuangongprop:process")
    
    local dlgXKCG = XiakeChuanGong.peekInstance()
    if dlgXKCG and XiakeChuanGong.IsVisible() then
        dlgXKCG:RefreshXKListProps(self.xkpropslist)
    end
end

local sxiakelist = require "protocoldef.knight.gsp.xiake.sxiakelist"
function sxiakelist:process()
    LogInfo("____sxiakelist:process")
    
    local num = #(self.xiakes)
    
    for i = 1, num, 1 do
        XiakeMng.AddXiake(self.xiakes[i])
    end
end

local sxiakebattlelist = require "protocoldef.knight.gsp.xiake.sxiakebattlelist"
function sxiakebattlelist:process()
    print("____sxiakebattlelist:process")
    
    local battlelist = {}
    local size = #(self.myxiakebattlelist)
    for i = 1, 4, 1 do
        if i <= size then
            battlelist[i] = self.myxiakebattlelist[i].xiakekey
        else
            battlelist[i] = 0
        end
    end
    
    XiakeMng.RefreshBattleList(battlelist[1], battlelist[2], battlelist[3], battlelist[4])
end

local saddxiake = require "protocoldef.knight.gsp.xiake.saddxiake"
function saddxiake:process()
    --print("____saddxiake:process")
    
    XiakeMng.AddXiake(self.xiakeinfo)
end

local sxiakeinfo = require "protocoldef.knight.gsp.xiake.sxiakeinfo"
function sxiakeinfo:process()
    --print("____sxiakeinfo:process")
    
    XiakeMng.AddXiakeDetail(self.xiakeinfo)
end

local supgradexiake = require "protocoldef.knight.gsp.xiake.supgradexiake"
function supgradexiake:process()
    print("____supgradexiake:process")
    
    XiakeMng.ProcessJinHua(self)
end

local supgradexiakepreview = require "protocoldef.knight.gsp.xiake.supgradexiakepreview"
function supgradexiakepreview:process()
    print("____supgradexiakepreview:process")
    
    XiakeMng.UpgradeXiakePreview(self.xiakekey, self.addexp)
end

local rmxkskill = require "protocoldef.knight.gsp.xiake.sremoveskill"
function rmxkskill:process()
-- 不会收到这条删除侠客技能的协议
end

local srspwmxiake = require "protocoldef.knight.gsp.xiake.srspwmxiake" 
function srspwmxiake:process()
	LogInfo("srspwmxiake process")
	if XiakeJiuguan.peekInstance() then
		XiakeJiuguan.peekInstance():InitXiakeInfo(self.configid)	
	end
end

local sextxiakeskill = require "protocoldef.knight.gsp.xiake.sextxiakeskill" 
function sextxiakeskill:process()
	LogInfo("sextxiakeskill process")
	XiakeMng.ExtXiakeSkill(self.xiakekey, self.skillnum)
end

local schangexiakezhenrong = require "protocoldef.knight.gsp.xiake.schangexiakezhenrong" 
function schangexiakezhenrong:process()
	LogInfo("schangexiakezhenrong process")
	--Set zhenrong and zhenfa
	XiakeMng.m_iZhenRong = self.zhenrong
	--set battleList
	local battlelist = {}
    local size = #(self.xiakelist)
    for i = 1, 4, 1 do
        if i <= size then
            battlelist[i] = self.xiakelist[i]
        else
            battlelist[i] = 0
        end
    end
    XiakeMng.RefreshBattleList(battlelist[1], battlelist[2], battlelist[3], battlelist[4])	
	--Refresh UI
	if self.reason == 1 then 
		FormationManager:getInstance():setMyFormation(self.zhenfa, 1)
	elseif self.reason == 3 then
		FormationManager:getInstance():setMyFormation(self.zhenfa, 0)
	elseif self.reason == 4 then
		FormationManager:getInstance():setMyFormation(self.zhenfa, 0)
	end

    if BuzhenXiake:peekInstance() ~= nil then
        BuzhenXiake:peekInstance():RefreshXiakes()
        BuzhenXiake:peekInstance():RefreshBattleOrder()
    end
end

local sweibosharenotify = require "protocoldef.knight.gsp.xiake.sweibosharenotify" 
function sweibosharenotify:process()

end

local supgradexiakeall = require "protocoldef.knight.gsp.xiake.supgradexiakeall"
function supgradexiakeall:process()
    print("____supgradexiakeall:process")

    local XiakeMng = require "ui.xiake.xiake_manager".RemoveXiakesFromKeyList(self.materialkeys)
    local jinhuaDlg = require "ui.xiake.jinhua_xiake".peekInstance()
    if jinhuaDlg ~= nil then
        jinhuaDlg:RefreshDieingXiakes()
        if self.changed == 1 then
            jinhuaDlg:PlayEffectJinhua(true)
        end
    end
    local myXiakeDlg = require "ui.xiake.myxiake_xiake".peekInstance()
    if myXiakeDlg ~= nil then
        myXiakeDlg:RefreshMyXiakes()
    end
end


