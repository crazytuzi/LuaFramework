-- Filename: EquipmentTableView.lua
-- Author: DJN
-- Date: 2014-08-13
-- Purpose: 主角更换技能tableView

module("EquipmentTableView", package.seeall)

require "script/ui/item/ItemUtil"
require "script/audio/AudioUtil"
require "script/ui/replaceSkill/ReplaceSkillData"
require "db/skill"
require "db/DB_Star"

require "script/ui/athena/AthenaData"
require "script/ui/replaceSkill/ReplaceSkillService"
require "script/ui/athena/AthenaService"

local _curMenuTag = nil     --当前处于哪个分页标签上
local _curList = {}         --供创建tableview用的信息
local _ksTagSpecialEquip = 1001
local _ksTagNormalEquip = 1002
--[[
    @des    :获取创建tableview用的数据表
    @param  :
    @return :
--]]

function getCurList( ... )
    _curMenuTag = EquipmentLayer.getCurMenuTag()
    if(_curMenuTag == _ksTagSpecialEquip)then
        _curList = ReplaceSkillData.getSpecialSkillList()

    elseif(_curMenuTag == _ksTagNormalEquip)then
        _curList = AthenaData.getNormalSkillList()
    end
    return _curList
end
function refreshCurList( ... )
    _curList = getCurList()
end
--[[
    @des    :创建tableView
    @param  :
    @return :创建好的tableView
--]]
function createTableView(sizeX,sizeY)
    refreshCurList()
    local h = LuaEventHandler:create(function(fn,p_table,a1,a2)     
        local r
        local cellNum = table.count(_curList)
    
        if fn == "cellSize" then
            r = CCSizeMake(575*g_fScaleX, 205*g_fScaleX)
        elseif fn == "cellAtIndex" then
            --用a1+1做下标创建cell
            a2 = createSpecialCell(cellNum - a1)
            r = a2
        elseif fn == "numberOfCells" then
            r = cellNum
        else
            print("other function")
        end

        return r
    end)
   -- return LuaTableView:createWithHandler(h, CCSizeMake(635*g_fScaleX, 750*g_fScaleX))
   return LuaTableView:createWithHandler(h, CCSizeMake(sizeX, sizeY))
 end

--[[
    @des    :创建特殊技能的cell
    @param  :奖励的位置，从1开始（即a1+1的值）
    @return :创建好的cell
--]]
function createSpecialCell(p_pos)

    local tCell = CCTableViewCell:create()
    tCell:setScale(g_fScaleX)
    --背景
    local cellBgSprite = CCScale9Sprite:create("images/reward/cell_back.png")
    cellBgSprite:setContentSize(CCSizeMake(635,200))
    cellBgSprite:setAnchorPoint(ccp(0,0))
    cellBgSprite:setPosition(ccp(1,5))
    tCell:addChild(cellBgSprite)

    --技能名称
    local nameStr = skill.getDataById(_curList[p_pos].feel_skill).name 
    local nameLabel  = CCRenderLabel:create(nameStr,g_sFontPangWa,25,1,ccc3(0x00,0x00,0x00),type_stroke)
    nameLabel:setColor(ccc3(0xe4,0x00,0xff))
    nameLabel:setAnchorPoint(ccp(0,0.5))
    nameLabel:setPosition(ccp(130,165))
    cellBgSprite:addChild(nameLabel)
    
    --头像
    require "script/ui/replaceSkill/ReplaceSkillLayer"
    local iconSprite = ReplaceSkillData.createSkillIcon(_curList[p_pos].feel_skill)
    iconSprite:setAnchorPoint(ccp(0,0))
    iconSprite:setPosition(ccp(20,80))
    cellBgSprite:addChild(iconSprite)

    --二级白色背景
    local whiteBgSprite = CCScale9Sprite:create("images/recycle/reward/rewardbg.png")
    whiteBgSprite:setContentSize(CCSizeMake(350,120))
    whiteBgSprite:setAnchorPoint(ccp(0,0))
    whiteBgSprite:setPosition(ccp(120,25))
    cellBgSprite:addChild(whiteBgSprite)
    --对于不是主角的技能需要展示图标的等级，主角的技能无等级
    if(_curMenuTag == _ksTagSpecialEquip and  _curList[p_pos].from == 1)then
        --等级
        local lvImage = CCSprite:create("images/common/lv.png")
        lvImage:setPosition(ccp(35,50))
        cellBgSprite:addChild(lvImage)

        local skillList = ReplaceSkillData.getSkillInfoBySid(_curList[p_pos].star_id)
        local skillInfo = ReplaceSkillData.getSkillById(skillList,_curList[p_pos].feel_skill)
        local levelLabel = CCRenderLabel:create(skillInfo.skillLevel,g_sFontPangWa,18,1,ccc3(0x00,0x00,0x00),type_stroke)
        levelLabel:setColor(ccc3(0xff,0xf6,0x00))
        levelLabel:setAnchorPoint(ccp(0,0))
        levelLabel:setPosition(ccp(75,50))
        cellBgSprite:addChild(levelLabel)
        --只有学习的技能才有师傅
        --技能属于武将信息
        local shuyuLabel = CCRenderLabel:create(GetLocalizeStringBy("djn_26"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        shuyuLabel:setColor(ccc3(0xfe, 0xdb, 0x1c))
        shuyuLabel:setAnchorPoint(ccp(0,0.5))
        shuyuLabel:setPosition(ccp(nameLabel:getContentSize().width + nameLabel:getPositionX()+10,165))
        cellBgSprite:addChild(shuyuLabel) 

        local  starLabelStr = DB_Star.getDataById(_curList[p_pos].star_tid).name
        local starLabel = CCRenderLabel:create(starLabelStr,g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        starLabel:setColor(ccc3(0xe4,0x00,0xff))
        starLabel:setAnchorPoint(ccp(0,0.5))
        starLabel:setPosition(ccp(shuyuLabel:getPositionX()+105,165))
        cellBgSprite:addChild(starLabel)

        local kuohao = CCRenderLabel:create(GetLocalizeStringBy("djn_36"),g_sFontPangWa,21,1,ccc3(0x00,0x00,0x00),type_stroke)
        kuohao:setColor(ccc3(0xfe, 0xdb, 0x1c))
        kuohao:setAnchorPoint(ccp(0,0.5))
        kuohao:setPosition(ccp(starLabel:getContentSize().width+starLabel:getPositionX()+1,165))
        cellBgSprite:addChild(kuohao)
        
    end
    local strSprite = nil
    local strStr = nil
    if(_curMenuTag == _ksTagSpecialEquip)then
        --怒
        strSprite = "images/hero/info/anger.png"
        strStr = GetLocalizeStringBy("key_2064")
    elseif(_curMenuTag == _ksTagNormalEquip)then
        --普
        strSprite = "images/hero/info/normal.png"
        strStr = GetLocalizeStringBy("zz_78")
    end
    
    local nuSprite = CCSprite:create(strSprite)
    nuSprite:setAnchorPoint(ccp(0,1))
    nuSprite:setPosition(ccp(9,100))
    whiteBgSprite:addChild(nuSprite)
    local nuStr = CCLabelTTF:create(strStr,g_sFontName,25)
    nuStr:setColor(ccc3(0xff,0xff,0xff))
    nuStr:setAnchorPoint(ccp(0.5,0.5))
    nuStr:setPosition(ccp(nuSprite:getContentSize().width*0.5,nuSprite:getContentSize().height*0.5))
    nuSprite:addChild(nuStr)

    
    --技能描述
    local desStr = skill.getDataById(_curList[p_pos].feel_skill).des
    --因为引擎把XXX%~XXX%算作一个字符，会发生无法换行的情况，所以拆分 XXX%~XXX% 中间加一个空格
    desStr = string.gsub(desStr,"~","~ ")
    local desLabel = CCLabelTTF:create(desStr,g_sFontName,21,CCSizeMake(275,100),kCCTextAlignmentLeft)
    desLabel:setAnchorPoint(ccp(0,1))
    desLabel:setColor(ccc3(0x78,0x25,0x00))
    desLabel:setPosition(ccp(47,100))
    whiteBgSprite:addChild(desLabel)

    --背景按钮层
    local bgMenu = CCMenu:create()
    bgMenu:setPosition(ccp(0,0))
    bgMenu:setTouchPriority(EquipmentLayer.getTouchPriority()-1)
    tCell:addChild(bgMenu)

    --被装上的技能按钮显示已装备
    --if(p_pos == 1  )then 
    if(_curList[p_pos].isOn )then 
        --已装备
            local equipedLabel = CCScale9Sprite:create("images/common/bg/seal_9s_bg.png")
            equipedLabel:setContentSize(CCSizeMake(120,64))
            equipedLabel:setAnchorPoint(ccp(0.5,0))
            equipedLabel:setPosition(545,50)
            cellBgSprite:addChild(equipedLabel)

            local equipedStr = CCRenderLabel:create(GetLocalizeStringBy("djn_28"),g_sFontPangWa,30,1,ccc3(0x00,0x00,0x00),type_stroke)
            equipedStr:setColor(ccc3(0xff,0xf6,0x00))
            equipedStr:setAnchorPoint(ccp(0.5,0.5))
            equipedStr:setPosition(ccp(equipedLabel:getContentSize().width*0.5,equipedLabel:getContentSize().height*0.5))
            equipedLabel:addChild(equipedStr)
    else
        --当前技能可以装备
        local equipButton = LuaCC.create9ScaleMenuItem("images/common/btn/btn_blue_n.png","images/common/btn/btn_blue_h.png",CCSizeMake(160, 83),
                                                        GetLocalizeStringBy("djn_27"),ccc3(0xfe, 0xdb, 0x1c),30,g_sFontPangWa,1, ccc3(0x00, 0x00, 0x00))
        
        equipButton:setAnchorPoint(ccp(0.5,0))
        if(_curMenuTag == _ksTagSpecialEquip)then
            equipButton:registerScriptTapHandler(specialEquipButtonCallFunc)
        elseif(_curMenuTag == _ksTagNormalEquip)then
            equipButton:registerScriptTapHandler(normalEquipButtonCallFunc)
        end
        equipButton:setPosition(ccp(545,50))
        bgMenu:addChild(equipButton,1,p_pos)
        end
    return tCell
end
--[[
    @des    :更换怒气技能按钮回调
    @param  :
    @return :
--]]
function specialEquipButtonCallFunc( tag ,item)
    -- 音效

    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    
    --完成换技能网络请求后的回调
    local backCb = function ( ... )
        --弹特效
        require "script/ui/replaceSkill/FlipCardLayer"
        FlipCardLayer.getSkillTip(skill.getDataById(_curList[tag].feel_skill).name)
        EquipmentLayer.doCloseCb()
    end
    --怒气技能有三种来源  自己、学习、星魂 在curlist中用from字段来区分 分别用 0 1 2 来代表
    --在更换的时候  因走的网络接口不同 所以列举讨论
    if(_curList[1].from == 0)then
        --当前装备的是自己的 
        if(_curList[tag].from == 1)then
            --要换成学习的
            ReplaceSkillService.changeSkill(_curList[tag].star_id,backCb)
        elseif(_curList[tag].from == 2)then
            --换成星魂的
            AthenaService.changeSkill(2,_curList[tag].feel_skill,backCb)
        end
    elseif(_curList[1].from == 1)then
        --当前装备的是学习的
        if(_curList[tag].from == 0)then
            --要换成自己的
            UserModel.backToUserSkill(2,backCb)
        elseif(_curList[tag].from == 1)then
            --要换成学习的
            ReplaceSkillService.changeSkill(_curList[tag].star_id,backCb)
        elseif(_curList[tag].from == 2)then
            --换成星魂的
            AthenaService.changeSkill(2,_curList[tag].feel_skill,backCb)
        end
    elseif(_curList[1].from == 2)then
        --当前装备的是星魂的
        if(_curList[tag].from == 0)then
            --要换成自己的
            UserModel.backToUserSkill(2,backCb)
            --ReplaceSkillService.changeSkill(0,EquipmentLayer.jumpPage )
        elseif(_curList[tag].from == 1)then
            --要换成学习的
            ReplaceSkillService.changeSkill(_curList[tag].star_id,backCb)
        elseif(_curList[tag].from == 2)then
            --换成星魂的
            AthenaService.changeSkill(2,_curList[tag].feel_skill,backCb)
        end
    end
    UserModel.setUserRangeSkill(_curList[tag].feel_skill,_curList[tag].from)

end
--[[
    @des    :更换普通技能按钮回调
    @param  :
    @return :
--]]
function normalEquipButtonCallFunc( tag ,item)
    -- 音效

    AudioUtil.playEffect("audio/effect/zhujiemian.mp3")
    --完成换技能网络请求后的回调
    local backCb = function ( ... )
        --弹特效
        require "script/ui/replaceSkill/FlipCardLayer"
        FlipCardLayer.getSkillTip(skill.getDataById(_curList[tag].feel_skill).name)
        EquipmentLayer.doCloseCb()
    end

    if(_curList[tag].from == 0)then
        UserModel.backToUserSkill(1,backCb)
    elseif(_curList[tag].from == 2)then
        AthenaService.changeSkill(1,_curList[tag].feel_skill,backCb)
    end
    UserModel.setUserNormalSkill(_curList[tag].feel_skill,_curList[tag].from)

end
