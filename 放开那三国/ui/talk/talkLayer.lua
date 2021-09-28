-- Filename: TalkLayer.lua
-- Author: k
-- Date: 2013-06-06
-- Purpose: 对话



require "script/utils/extern"
require "script/utils/LuaUtil"
--require "amf3"
-- 模块声明
module("TalkLayer", package.seeall)

local baseHeight = CCDirector:sharedDirector():getWinSize().height*0.15

local IMG_PATH = "images/talk/"				-- 图片主路径

local m_baseLayer           -- 基础层
local m_leftPerson			-- 左侧人物
local m_rightPerson          -- 右侧人物
local m_labelBg			-- 文字背景
local m_nameLabelBg
local m_nameLabel			-- 名字LABEL
local m_dialogLabel          -- 对话LABEL

local m_talkSimple
local m_currentDialog

local m_dialogLabel          -- 对话LABEL
local m_callbackFunction          -- 对话LABEL


function gettalkById(talkID)
    --print("===========gettalkById=============",talkID,#talk)
    if(Platform.getPlatformFlag() == "ios_japan" or Platform.getPlatformFlag() == "Android_japan" )then
        if( UserModel.getUserSex() == 2)then  
            -- 女主
            require "db/talk_woman" 
        else
            -- 男主
            require "db/talk_man"
        end
    else
        require "db/talk"
    end
    for i=1,#talk do
        --print("===========talk=============",i)
        
        --寻找当前ID的TALK
        --print("gettalkById:",talk[i].id,talkID,(talk[i].id == ("" .. talkID)))
        if(talk[i].id == ("" .. talkID)) then
            local result = {}
            result.id = tonumber(talk[i].id)
            result.tips = talk[i].tips
            result.dialog = {}
            if(#(talk[i])>0)then
                for j=1,#(talk[i]) do
                    result.dialog[j] = talk[i][j]
                end
            else
                result.dialog[1] = talk[i].dialog
            end
            return result
        end
    end
end

function setCallbackFunction(callbackFunc)
    m_callbackFunc = callbackFunc
end

local function getNextDialog()
    local index
    if(m_currentDialog==nil)then
        index = 1
    else
        --print("getNextDialog:",index,m_currentDialog.option.data)
        index = tonumber( m_currentDialog.option.data)
    end
    if(index==nil)then
        return false
    end
    --print_table("m_talkSimple",m_talkSimple)
    --print("getNextDialog:",index,#(m_talkSimple.dialog))
    for i=1,#(m_talkSimple.dialog) do
        --print(m_talkSimple.dialog[i].id == index)
        if(m_talkSimple.dialog[i].id == ("" .. index)) then
            m_currentDialog = m_talkSimple.dialog[i]
            return true
        end
    end
    
    return false
end

function stopCurrentTalk()
    if(m_baseLayer~=nil)then
        m_baseLayer:removeFromParentAndCleanup(true)
        m_baseLayer = nil
    end
end

--显示下一条对话
local function showNext()
    if(getNextDialog() ~= true) then
        if(m_baseLayer~=nil)then
            m_baseLayer:removeFromParentAndCleanup(true)
        end
        m_baseLayer = nil
        --根据m_currentDialog.option.type打开点东西
        --m_currentDialog.option.data = "11#1002"
        
        if(m_currentDialog.option.data ~= nil and string.sub(m_currentDialog.option.data, 1, 3)=="13#")then
            local copyId = string.sub(m_currentDialog.option.data, 4, string.len(m_currentDialog.option.data))
            local newCopy = nil
            require "db/DB_Copy"
            newCopy = DB_Copy.getDataById(copyId)
            
            if(newCopy~=nil)then
                require "script/ui/tip/AlertTip"
                AlertTip.showAlert( GetLocalizeStringBy("key_3039") .. newCopy.name .. GetLocalizeStringBy("key_2857"), nil, false, nil)
            end
        end
        
        --回调
        if(nil~=m_callbackFunc) then
            print("showNext: m_callbackFunc")
            m_callbackFunc()
        end
        m_callbackFunc = nil
        
        return
    end
    if(m_currentDialog.option.type == "7") then
        require "script/ui/copy/FortsLayout"
        FortsLayout.transBG(m_baseLayer)
      
    end
    
    --更新左侧人物
    if(m_currentDialog.leftHeaderId~=nil and tonumber(m_currentDialog.leftHeaderId)~=0) then
        m_leftPerson:setVisible(true)

        
        local imageFile
        local positionX = 0
        local positionY = 0
        if(tonumber(m_currentDialog.leftHeaderId)==999) then
            require "script/model/user/UserModel"
            require "db/DB_Heroes"
            --print("UserModel.getUserInfo().htid",UserModel.getUserInfo().htid)
            if(UserModel.getUserInfo()==nil)then
                imageFile = "quan_jiang_guojia.png"
            else
                imageFile = DB_Heroes.getDataById(tonumber(UserModel.getUserInfo().htid)).body_img_id
            end
            --imageFile = DB_Heroes.getDataById(tonumber(20001)).body_img_id
            --获得坐标
            require "db/DB_Npcheader"
            local npcList = DB_Npcheader.getArrDataByField("body_image",imageFile)
            --print_table("",npcList)
            --print("============",#npcList)
            if(npcList==nil or #npcList==0)then
                positionX = 640*0.25
                positionY = 0
            else
                positionX = npcList[1].position_x
                positionY = npcList[1].position_y
            end
        else
            require "db/DB_Npcheader"
            local npc = DB_Npcheader.getDataById(tonumber(m_currentDialog.leftHeaderId))
            --print_table("",npc)
            --print("npc:",npc.position_x,npc.position_y)
            if(npc~=nil)then
                imageFile = npc.body_image
                positionX = npc.position_x
                positionY = npc.position_y
            end
        end
        --print("shownext imageFile,positionX,positionY:",imageFile,positionX,positionY)
        if(imageFile~=nil)then
            imageFile = "images/base/hero/body_img/" .. imageFile
            positionX = positionX==nil and 0 or positionX
            positionY = positionY==nil and 0 or positionY
            local texture = CCTextureCache:sharedTextureCache():addImage(imageFile)
            m_leftPerson:setTexture(texture)
            m_leftPerson:setTextureRect(CCRectMake(0,0,texture:getContentSize().width,texture:getContentSize().height))
            m_leftPerson:setPositionX(positionX/640*g_winSize.width)
            m_leftPerson:setPositionY(baseHeight+positionY/640*g_winSize.width)
        end
         --]]
    else
        m_leftPerson:setVisible(false)
    end
    --更新右侧人物
    --print("=================" , m_currentDialog.rightHeaderId)
    if(m_currentDialog.rightHeaderId~=nil and tonumber(m_currentDialog.rightHeaderId)~=0) then
        m_rightPerson:setVisible(true)

        
        local imageFile
        local positionX = 0
        local positionY = 0
        if(tonumber(m_currentDialog.rightHeaderId)==999) then
            require "script/model/user/UserModel"
            require "db/DB_Heroes"
            if(UserModel.getUserInfo()==nil)then
                imageFile = "quan_jiang_guojia.png"
            else
                imageFile = DB_Heroes.getDataById(tonumber(UserModel.getUserInfo().htid)).body_img_id
            end

            --获得坐标
            require "db/DB_Npcheader"
            local npcList = DB_Npcheader.getArrDataByField("body_image",imageFile)
            if(npcList==nil or #npcList==0)then
                positionX = 640*0.25
                positionY = 0
            else
                positionX = npcList[1].position_x
                positionY = npcList[1].position_y
            end
        else
            require "db/DB_Npcheader"
            local headId = tonumber(m_currentDialog.rightHeaderId)

            local npc = DB_Npcheader.getDataById(headId)

            if(npc~=nil)then
                imageFile = npc.body_image
                positionX = npc.position_x
                positionY = npc.position_y
            end
        end
        
        --print("shownext imageFile,positionX,positionY:",imageFile,positionX,positionY)
        
        if(imageFile~=nil)then
            
            positionX = positionX==nil and 0 or positionX
            positionY = positionY==nil and 0 or positionY
            positionX = 640-positionX
            imageFile = "images/base/hero/body_img/" .. imageFile
            local texture = CCTextureCache:sharedTextureCache():addImage(imageFile)
            m_rightPerson:setTexture(texture)
            m_rightPerson:setTextureRect(CCRectMake(0,0,texture:getContentSize().width,texture:getContentSize().height))
            m_rightPerson:setPositionX(positionX/640*g_winSize.width)
            m_rightPerson:setPositionY(baseHeight+positionY/640*g_winSize.width)
            --m_rightPerson:setFlipX(true)
        end
         --]]
    else
        m_rightPerson:setVisible(false)
    end
    --更新对话名字
    if(m_currentDialog.talkName~=nil and m_currentDialog.talkName~="") then
        m_nameLabel:setVisible(true)
        if (m_currentDialog.talkName=="[HERO]") then
            require "script/model/user/UserModel"
            local userName = GetLocalizeStringBy("key_1743")
            if(UserModel.getUserInfo() ~= nil and UserModel.getUserInfo().uname ~=nil) then
                userName = UserModel.getUserInfo().uname
            end
            m_nameLabel:setString(userName)
        else
            m_nameLabel:setString(m_currentDialog.talkName)
        end
    else
        m_nameLabel:setVisible(false)
    end
    --更新对话名字
    if(m_currentDialog.msg~=nil and m_currentDialog.msg~="") then
        m_dialogLabel:setVisible(true)
        require "script/model/user/UserModel"
        local userName = GetLocalizeStringBy("key_1743")
        if(UserModel.getUserInfo() ~= nil and UserModel.getUserInfo().uname ~=nil) then
            userName = UserModel.getUserInfo().uname
        end
        local str = string.gsub(m_currentDialog.msg,"%b[HERO]",userName)
        m_dialogLabel:setString(str)
    else
        m_dialogLabel:setVisible(false)
    end
    --更新名字位置和人物明暗
    if(m_currentDialog.dir=="0")then
        m_nameLabelBg:setPositionX(115)
        m_leftPerson:setColor(ccc3(255,255,255))
        m_rightPerson:setColor(ccc3(111,111,111))
        m_baseLayer:reorderChild(m_leftPerson,0)
        m_baseLayer:reorderChild(m_rightPerson,-1)
    else
        m_nameLabelBg:setPositionX(525)
        m_leftPerson:setColor(ccc3(111,111,111))
        m_rightPerson:setColor(ccc3(255,255,255))
        m_baseLayer:reorderChild(m_leftPerson,-1)
        m_baseLayer:reorderChild(m_rightPerson,0)
    end
end

local function layerTouch(eventType, x, y)
    if eventType == "began" then
            return true
        elseif eventType == "moved" then
            return true
        else
            showNext()
            return true
    end
end

function createTalkLayer(talkID)
    print("createTalkLayer id:",talkID)
    m_talkSimple = gettalkById(talkID)
    
    if(m_talkSimple==nil) then
        return nil
    end
    
    m_baseLayer = CCLayerColor:create(ccc4(11,11,11,111))
    
    m_labelBg = CCSprite:create(IMG_PATH .. "dialogbg.png")
    m_labelBg:setAnchorPoint(ccp(0,0))
    m_labelBg:setPosition(0,baseHeight)
    m_baseLayer:addChild(m_labelBg,1)
    
    local bgSize = m_labelBg:getContentSize()
    local scale = CCDirector:sharedDirector():getWinSize().width/bgSize.width
    m_labelBg:setScale(scale)
    
    m_nameLabelBg = CCScale9Sprite:create(CCRectMake(50, 20, 1, 10),IMG_PATH .. "namebg.png")
    m_nameLabelBg:setContentSize(CCSizeMake(230,53))
    m_nameLabelBg:setAnchorPoint(ccp(0.5,0))
    m_nameLabelBg:setPosition(bgSize.width*0.18,bgSize.height*0.94)
    m_labelBg:addChild(m_nameLabelBg,-1)
    
    
    m_nameLabel = CCLabelTTF:create(GetLocalizeStringBy("key_2884"),g_sFontPangWa,30)
    m_nameLabel:setColor(ccc3(0xff,0xea,0x00))
    m_nameLabel:setAnchorPoint(ccp(0.5,0.5))
    m_nameLabel:setPosition(115,24)
    m_nameLabelBg:addChild(m_nameLabel)
    
    m_dialogLabel = CCLabelTTF:create(GetLocalizeStringBy("key_10059"),g_sFontName,28,CCSizeMake(bgSize.width*0.9, bgSize.height*0.75),kCCTextAlignmentLeft,kCCVerticalTextAlignmentTop)
    m_dialogLabel:setAnchorPoint(ccp(0,1))
    m_dialogLabel:setPosition(bgSize.width*0.05,bgSize.height*0.85)
    m_labelBg:addChild(m_dialogLabel)
    
    m_leftPerson = CCSprite:create()
    m_leftPerson:setAnchorPoint(ccp(0.5,0))
    m_leftPerson:setPosition(CCDirector:sharedDirector():getWinSize().width*0.25,baseHeight+100)
    m_leftPerson:setScale(scale)
    m_baseLayer:addChild(m_leftPerson)
    
    m_rightPerson = CCSprite:create()
    m_rightPerson:setAnchorPoint(ccp(0.5,0))
    m_rightPerson:setPosition(CCDirector:sharedDirector():getWinSize().width*0.75,baseHeight+100)
    m_rightPerson:setScale(scale)
    m_baseLayer:addChild(m_rightPerson)
    
    m_baseLayer:setTouchEnabled(true)
    m_baseLayer:registerScriptTouchHandler(layerTouch,false,-1100,true)
    
    
    m_currentDialog = nil
    showNext()
    
    return m_baseLayer
end


-- 退出场景，释放不必要资源
function release (...) 

end
