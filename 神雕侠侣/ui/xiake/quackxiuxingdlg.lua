require "ui.dialog"
QuackXiuxingDlg = {}
setmetatable(QuackXiuxingDlg, Dialog)
QuackXiuxingDlg.__index = QuackXiuxingDlg

------------------- public: -----------------------------------
---- singleton /////////////////////////////////////////------
local _instance;
function QuackXiuxingDlg.getInstance()
    if not _instance then
        _instance = QuackXiuxingDlg:new()
        _instance:OnCreate()
    end
    
    return _instance
end

function QuackXiuxingDlg.getInstanceAndShow()
    if not _instance then
        _instance = QuackXiuxingDlg:new()
        _instance:OnCreate()
	else
		_instance:SetVisible(true)
    end
    
    return _instance
end

function QuackXiuxingDlg.getInstanceNotCreate()
    return _instance
end

function QuackXiuxingDlg.DestroyDialog()
	if _instance then 
        _instance:removeAllEffect()
		_instance:OnClose()		
		_instance = nil
      package.loaded["ui.xiake.quackxiuxingdlg"] = nil
	end

end

function QuackXiuxingDlg.ToggleOpenClose()
	if not _instance then 
		_instance = QuackXiuxingDlg:new() 
		_instance:OnCreate()
	else
		if _instance:IsVisible() then
			_instance:SetVisible(false)
		else
			_instance:SetVisible(true)
		end
	end
end
function QuackXiuxingDlg.GetLayoutFileName()
    return "quackxiuxing.layout"
end
function QuackXiuxingDlg:OnCreate()
    Dialog.OnCreate(self)
    local winMgr = CEGUI.WindowManager:getSingleton()
    self.btn = CEGUI.toPushButton(winMgr:getWindow("quackxiuxing/found/imgbtn"))
	self.btn:subscribeEvent("Clicked", self.HandleClicked, self)

    self.xiuxing = CEGUI.toPushButton(winMgr:getWindow("quackxiuxing/found/up/txt/jinjie"))
    self.xiuxing:subscribeEvent("Clicked", self.XiuXingJingduHandleClicked, self)

    self.prop = {}
    self.ball = {}
    self.line = {}

 
    self.prop[140] = winMgr:getWindow("quackxiuxing/found/case/left/num0" )   --sheng ming
    self.prop[810] = winMgr:getWindow("quackxiuxing/found/case/left/num1" ) -- shanghai
    self.prop[80] = self.prop[810]                                          -- wai / nei  
    self.prop[100] = winMgr:getWindow("quackxiuxing/found/case/left/num2" ) --wai fang 
    self.prop[820] = winMgr:getWindow("quackxiuxing/found/case/left/num3" ) -- nei fang
    self.prop[1230] = winMgr:getWindow("quackxiuxing/found/case/left/num4" ) -- jia qiang feng yin 
    self.prop[1240] = winMgr:getWindow("quackxiuxing/found/case/left/num5" ) -- feng yin kang xing
    self.prop[1260] = winMgr:getWindow("quackxiuxing/found/case/left/num6" ) --bao deng ji
    self.prop[1250] = self.prop[1260]                                       -- wai / nei  
    self.prop[930] = winMgr:getWindow("quackxiuxing/found/case/left/num7" ) --   bao cheng du
    self.prop[220] = self.prop[930]                                         -- wai / nei  
    self.prop[130] = winMgr:getWindow("quackxiuxing/found/case/left/num8" ) -- su du


    self.neigongshanghai = winMgr:getWindow("quackxiuxing/found/case/left/neigongshanghai")
    self.waigongshanghai = winMgr:getWindow("quackxiuxing/found/case/left/waigongshanghai")
    self.waibaochengdu = winMgr:getWindow("quackxiuxing/found/case/left/waibaochengdu")
    self.neibaochengdu = winMgr:getWindow("quackxiuxing/found/case/left/neibaochengdu")
    self.waibaodengji = winMgr:getWindow("quackxiuxing/found/case/left/waibaodengji")
    self.neibaodengji = winMgr:getWindow("quackxiuxing/found/case/left/neibaodengji")

    self.selectTool = winMgr:getWindow("quackxiuxing/found/up/txt/effect")
    
    self.remainNum = winMgr:getWindow("quackxiuxing/found/txt11")



    for i = 1,11 do
        if i == 6 or i == 11 then
            self.ball[i] = CEGUI.toSkillBox(winMgr:getWindow("quackxiuxing/found/up/txt/" .. i .. "on"))
            self.ball[i*100] = CEGUI.toSkillBox(winMgr:getWindow("quackxiuxing/found/up/txt/" .. i .. "off"))

            self.ball[i]:setID(i)
            self.ball[i]:subscribeEvent("MouseButtonUp", self.HandleBallClicked, self)

            self.ball[i*100]:setID(i*100)
            self.ball[i*100]:subscribeEvent("MouseButtonUp", self.HandleBallClicked, self)
            self:setBallImage(self.ball[i],false)
        else
            self.ball[i] = winMgr:getWindow("quackxiuxing/found/up/txt/" .. tostring(i) )
            self.ball[i]:setID(i)
            self.ball[i]:subscribeEvent("MouseButtonUp", self.HandleBallClicked, self)
            self:setBallImage(self.ball[i],false)
        end
            
      
        if i ~= 1 then
            self.line[i] = winMgr:getWindow("quackxiuxing/found/up/txt/line" .. tostring(i) )
            self.line[i]:setID(i)
            self:setLineImage(self.line[i],false)
        end
    end




    self.progress = CEGUI.Window.toProgressBar(winMgr:getWindow("quackxiuxing/found/case/bar"))
    self.progressText = winMgr:getWindow("quackxiuxing/found/case/bar/txt")

    self.m_pXiakeFrame = winMgr:getWindow("quackxiuxing/found/img")
    self.m_pIcon = winMgr:getWindow("quackxiuxing/found/img/head")
    self.m_pName = winMgr:getWindow("quackxiuxing/found/img/name")
    self.m_pTxtLevel = winMgr:getWindow("quackxiuxing/found/img/head/txt")
    self.m_pJieIcon = winMgr:getWindow("quackxiuxing/found/img/head/ima")
    
    self.jingjiePoint = 0
   
end

------------------- private: -----------------------------------
function QuackXiuxingDlg:new()
    local self = {}
    self = Dialog:new()
    setmetatable(self, QuackXiuxingDlg)
    return self
end
function QuackXiuxingDlg:HandleClicked(args)
    if not self.Xiake or not XiakeMng.m_vXiakes  then return end
    for k,v in pairs(XiakeMng.m_vXiakes) do
        if self.Xiake["xiakeid"] == v["xiakeid"] and self.Xiake["xiakekey"] ~= k then
            local id = CEGUI.toWindowEventArgs(args).window:getID()
            local p = require("protocoldef.knight.gsp.xiake.practice.cxiakepractice"):new()
            p.xiakekey = self.Xiake["xiakekey"]
            p.materialxiakekey = k
            p.pointkey = self.positionToAttribId[self.pointid].pointkey
            require("manager.luaprotocolmanager"):send(p)
            return
        end
    end
    GetGameUIManager():AddMessageTip(knight.gsp.message.GetCMessageTipTableInstance():getRecorder(146123).msg)
end

function QuackXiuxingDlg:XiuXingJingduHandleClicked(args)
    local tip = require("ui.xiake.jingjietip").SetTip(self.jingjieLevel , self.jingjiePoint)
    
    local pos = self.xiuxing:GetScreenPos()
    tip:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 , pos.x + 90 ), CEGUI.UDim(0,pos.y + 20))) 
end



function QuackXiuxingDlg:HandleBallClicked(args)
    local id = CEGUI.toWindowEventArgs(args).window:getID()
    if not id then return end
    if id > 100 then id = id / 100 end
    self:selectedState(id)
    if not self.positionToAttribId[id] then return end
    self:setProp(self.positionToAttribId[id])
    local tip = require("ui.xiake.pointtip").SetTip(self.positionToAttribId[id].pointkey)
    local pos = CEGUI.toWindowEventArgs(args).window:GetScreenPos()
    local sizeball = CEGUI.toWindowEventArgs(args).window:getPixelSize()
    local sizetip = tip:GetWindow():getPixelSize()
    if id >= 8 then
        tip:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 , pos.x - sizetip.width - 5), CEGUI.UDim(0,pos.y + sizeball.height*0.5))) 
    else
        tip:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0 , pos.x + sizeball.width), CEGUI.UDim(0,pos.y + sizeball.height))) 
    end
   
 --  self.m_animStart = CEGUI.UVector2(CEGUI.UDim(pos.x.scale, pos.x.offset),CEGUI.UDim(pos.y.scale, pos.y.offset))




   
 --  tip:GetWindow():setPosition(CEGUI.UVector2(CEGUI.UDim(0, 0), CEGUI.UDim(0, (i - 1) * v.cell:GetWindow():getPixelSize().height + 1))) 


 
   
    

   




end





function QuackXiuxingDlg:setLineImage(w,b)
    if not w then return end
    local id = w:getID()
    if not id then return end
    if  b then
        if id == 6 or id == 11 then
            w:setProperty("Image", "set:MainControl38 image:xueweixian1")
        elseif id == 3 or id == 8 then
            w:setProperty("Image", "set:MainControl38 image:xueweixian3")
        else
            w:setProperty("Image", "set:MainControl38 image:xueweixian2")
        end
    else
        if id == 6 or id == 11 then
            w:setProperty("Image", "set:MainControl38 image:xueweixianhui1")
        elseif id == 3 or id == 8 then
            w:setProperty("Image", "set:MainControl38 image:xueweixianhui3")
        else
            w:setProperty("Image", "set:MainControl38 image:xueweixianhui2")
        end
    end
end



function QuackXiuxingDlg:setBallImage(w,b)
    if not w then return end
    local id = w:getID()
    if not id then return end
    if id == 6 or id == 11 then
       --seticon to process this
       return
    end
 

    if not b then
        w:setProperty("Image", "set:MainControl38 image:xiakeyuanzhenghuise")
  --[[  else
        if id == 1 then
            w:setProperty("Image", "set:MainControl38 image:xiakeyuanzhenghongse")
        elseif id >= 7 then
            w:setProperty("Image", "set:MainControl38 image:xiakeyuanzhenghuangse")
        else
            w:setProperty("Image", "set:MainControl38 image:xiakeyuanzhengzise")
        end
]]
    end
end




function QuackXiuxingDlg:setXuewei(id,b,level)
    self:setLineImage(self.line[id],b)
    self:setBallImage(self.ball[id],b)
    self:ballActivedEffect(id,level)
end


function QuackXiuxingDlg:selectedState(id)
    if not id then return end
    self.pointid = id

 

    local sizeball = self.ball[id]:getPixelSize()
    local pos = self.ball[id]:getPosition()
 
    GetGameUIManager():RemoveUIEffect(self.selectTool)
    self.selectTool:setPosition(CEGUI.UVector2(CEGUI.UDim(pos.x.scale , pos.x.offset + sizeball.width*0.5), CEGUI.UDim(pos.y.scale , pos.y.offset + sizeball.height*0.5)))
    
    if id == 11 or id == 6 then  
        GetGameUIManager():AddUIEffect(self.selectTool, MHSD_UTILS.get_effectpath(10436))
    else
        GetGameUIManager():AddUIEffect(self.selectTool, MHSD_UTILS.get_effectpath(10437))
    end
 
end



function QuackXiuxingDlg:ballActivedEffect(id,level)
    if not id then return end
    GetGameUIManager():RemoveUIEffect(self.ball[id])
    GetGameUIManager():RemoveUIEffect(self.ball[id*100])
    
    if (id == 6 or id == 11) and level == 1 then
      --  GetGameUIManager():AddUIEffect(self.ball[id*100], MHSD_UTILS.get_effectpath(10441))
    elseif id == 6  and level == 2 then
    --    GetGameUIManager():AddUIEffect(self.ball[id*100], MHSD_UTILS.get_effectpath(10441))
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10467))
    elseif id == 11  and level == 2 then
     --   GetGameUIManager():AddUIEffect(self.ball[id*100], MHSD_UTILS.get_effectpath(10441))
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10466))
    elseif id == 1 then
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10438))
    elseif id >= 7  then
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10439))
    else
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10440))
    end
end

function QuackXiuxingDlg:removeAllEffect()
    for i = 1,11 do
        GetGameUIManager():RemoveUIEffect(self.ball[i])
    end
    GetGameUIManager():RemoveUIEffect(self.selectTool)
    GetGameUIManager():RemoveUIEffect(self.ball[600])
    GetGameUIManager():RemoveUIEffect(self.ball[1100])
end


function QuackXiuxingDlg:practiceResult(id)
    if not id then return end
    GetGameUIManager():RemoveUIEffect(self.ball[id])
    if id == 1 then
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10442),false)
    elseif id >= 7  then
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10443),false)
    else
        GetGameUIManager():AddUIEffect(self.ball[id], MHSD_UTILS.get_effectpath(10444),false)
    end
end

function QuackXiuxingDlg:jingjieEffect(level)
    local jingjieEffectID = {10462,10463,10464,10465,10446}
    if not level or not jingjieEffectID[level] then return end
    if not GetPlayRoseEffecstManager() then 
        CPlayRoseEffecst:NewInstance()
    end
    if GetPlayRoseEffecstManager() then
     GetPlayRoseEffecstManager():PlayLevelUpEffect(jingjieEffectID[level], 0) 
    end
end

function QuackXiuxingDlg:setRemainNum()
    if not self.Xiake or not XiakeMng.m_vXiakes  then 
        self.remainNum:setVisible(false)
    end
    local remain = 0
    for k,v in pairs(XiakeMng.m_vXiakes) do
        if self.Xiake["xiakeid"] == v["xiakeid"] and self.Xiake["xiakekey"] ~= k then
            remain = remain + 1
        end
    end
    self.remainNum:setVisible(true)
    self.remainNum:setText(remain)
end

function QuackXiuxingDlg:Process(points,xiakekey,level,init)
    if not xiakekey then return end
    local aXiake = XiakeMng.m_vXiakes[xiakekey]
    if not aXiake then return end 
    self.Xiake = aXiake
    self:SetXiakeInfo(aXiake)
    self.btn:setID(xiakekey)
    self.positionToAttribId = {}
    self.jingjiePoint = 0
    local cfg = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticevalueconfig")
    local cfg2 = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticeconfig")
    if cfg and cfg2 then
        local recxia = cfg2:getRecorder(aXiake.xiakeid)
        local donePoint = {}
        if recxia then
            for i = 1,#self.ball do
                self.positionToAttribId[i] = {}
                self.positionToAttribId[i].pointkey = recxia["point" .. i]
                self.positionToAttribId[i].exp = 0
            end
        end
        if points then
            for k = 1,#points do
                local rec = cfg:getRecorder(points[k].pointkey)
                self.positionToAttribId[points[k].pointid].pointkey = points[k].pointkey
                self.positionToAttribId[points[k].pointid].exp = points[k].curexp
                if rec.score then
                    self.jingjiePoint = self.jingjiePoint + rec.score
                end
                if rec.score ~= 0 then
                    if rec.nextLevel == 0 then
                        self:setXuewei(points[k].pointid ,true, 2)
                        donePoint[points[k].pointid] = 2
                    elseif rec.nextLevel ~= 0  then
                        self:setXuewei(points[k].pointid ,true, 1)
                        donePoint[points[k].pointid] = 1
                    end
                end
            end
        end
        self:setIcon(donePoint,recxia)
    end

    if init then
        self:setProp(self.positionToAttribId[1])
        self:selectedState(1)
    else
        self:setProp(self.positionToAttribId[self.pointid])
        self:selectedState(self.pointid)
    end

    if level then
        if self.jingjieLevel and level > self.jingjieLevel  then
            self:jingjieEffect(level)
        end
        self.jingjieLevel = level
        self.xiuxing:setProperty("HoverImage", "set:MainControl43 image:xiakexiuxing" .. level )
        self.xiuxing:setProperty("NormalImage", "set:MainControl43 image:xiakexiuxing" .. level )
        self.xiuxing:setProperty("PushedImage", "set:MainControl43 image:xiakexiuxing" .. level )
    end
    
    self:setRemainNum()
end

function QuackXiuxingDlg:setIcon(donePoint,cfg)
    if not cfg then return end
    if donePoint[6] then
        self.ball[6]:SetBackGroundEnable(true)
        self.ball[600]:SetBackGroundEnable(false)
        self.ball[6]:SetImage(GetIconManager():GetSkillIconByID(cfg.imageAon))
    else
        self.ball[6]:SetBackGroundEnable(false)
        self.ball[600]:SetBackGroundEnable(true)
        self.ball[600]:SetImage(GetIconManager():GetSkillIconByID(cfg.imageAoff))
    end

    if donePoint[11] then
        self.ball[11]:SetBackGroundEnable(true)
        self.ball[1100]:SetBackGroundEnable(false)
        self.ball[11]:SetImage(GetIconManager():GetSkillIconByID(cfg.imageBon))
    else
        self.ball[11]:SetBackGroundEnable(false)
        self.ball[1100]:SetBackGroundEnable(true)
        self.ball[1100]:SetImage(GetIconManager():GetSkillIconByID(cfg.imageBoff))
    end
 
end

function QuackXiuxingDlg:SetXiakeInfo()
    if not self.Xiake then return end 
    local aXiake = self.Xiake
    local aXiakeID = aXiake.xiakeid;
    local monster = knight.gsp.npc.GetCMonsterConfigTableInstance():getRecorder(aXiakeID);
    local shape= knight.gsp.npc.GetCNpcShapeTableInstance():getRecorder(monster.modelID);
    
    --[[
            if self.m_pElite then
                self.m_pElite:setVisible(XiakeMng.IsElite(aXiake.xiakekey))
            end]]

    local path = GetIconManager():GetImagePathByID(shape.headID):c_str();
    self.m_pIcon:setProperty("Image", path);
    local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(aXiakeID);
    self.m_pJieIcon:setProperty("Image", XiakeMng.eLvImages[1]);

    self.m_pTxtLevel:setText(tostring(GetDataManager():GetMainCharacterLevel()));
    self.m_pName:setText(scene_util.GetPetNameColor(xkxx.color)..xkxx.name);
    self.m_pXiakeFrame:setProperty("Image", XiakeMng.eXiakeFrames[xkxx.color]);



end




function QuackXiuxingDlg:setProp(positionToAttribId)
    if not self.Xiake or not positionToAttribId then return end 
    local xiakeData = self.Xiake
    local xkxx = knight.gsp.npc.GetCXiakexinxiTableInstance():getRecorder(xiakeData.xiakeid)
    self:setWai(xkxx.waigong == 1)
  --[[  self.prop[1]:setText(string.format("%d", xiakeData.datas[140]))
    self.prop[2]:setText(string.format("%d", xiakeData.datas[80]))
    
    self.prop[3]:setText(string.format("%d", xiakeData.datas[100]))
    self.prop[4]:setText(string.format("%d", xiakeData.datas[820]))
    self.prop[5]:setText(string.format("%d", xiakeData.datas[130]))
 

for k,v in pairs(xiakeData.datas) do

print("ssssssssss", k,v)

end

   ]]
   self:setWai(xkxx.waigong == 1)
    for k,v in pairs(self.prop) do
        local continue = false
        if xkxx.waigong == 1 and (k == 810 or k == 1260 or k == 930) then
            continue = true
       elseif xkxx.waigong == 0 and (k == 80 or k == 1250 or k == 220) then
            continue = true
        end

        if not continue then
            v:setText("0")
            if xiakeData.datas[k] then
                v:setText(string.format("%d", xiakeData.datas[k]))
            end
        end
    end

    
    local cfg = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticevalueconfig"):getRecorder(positionToAttribId.pointkey)
    if not cfg then return end
    
    if  cfg.nextLevel ~= 0 then 
        self.progressText:setText(tostring(positionToAttribId.exp) .. "/" .. tostring(cfg.levelExp))
        self.progress:setProgress(positionToAttribId.exp / cfg.levelExp)
    else
        self.progressText:setText(tostring(cfg.levelExp) .. "/" .. tostring(cfg.levelExp))
        self.progress:setProgress(cfg.levelExp / cfg.levelExp)
        return 
    end
    
    local cfg = require("manager.beanconfigmanager").getInstance():GetTableByName("knight.gsp.npc.cxiakepracticevalueconfig"):getRecorder(cfg.nextLevel)
    
    if not cfg then return end

    for i = 1,4 do
        if cfg["attribId_" .. i] ~= 0 and self.prop[cfg["attribId_" .. i] - 1] then
            local postfix = ""
            if cfg["attribId_" .. i] == 220 or cfg["attribId_" .. i] == 930 then
                postfix = "%"
            end
            self.prop[cfg["attribId_" .. i] - 1]:setText( self.prop[cfg["attribId_" .. i] - 1]:getText() .. "[colour='FF00FF00']+" .. cfg["attribValue_" .. i .. postfix]) 
        end
    end

end




function QuackXiuxingDlg:setWai(flag)
    self.neigongshanghai:setVisible(not flag)
    self.waigongshanghai:setVisible(flag)

    self.neibaochengdu:setVisible(not flag)
    self.waibaochengdu:setVisible(flag)
    
    self.neibaodengji:setVisible(not flag)
    self.waibaodengji:setVisible(flag)
end







return QuackXiuxingDlg
