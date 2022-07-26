require"Lang"
UILoot={
  isLoot = nil -- 是否抢夺中
}
local scrollView = nil
local chipItem = nil
local LootFlag = nil  --- 1 功法抢夺 2 技能抢夺 3 宝物抢夺
local LootDownFlag = nil
local ui_text_time_left =nil
local ui_text_time = nil
local ui_selectedFrame = nil
local lootThing ={}
local instPlayerLootId  = nil
local pageView = nil
local pageViewItem = nil
local _pageView = nil
local positionY = nil
local positionY_one = nil
UILoot.countDownTime = 0
UILoot.ScheduleId = nil
UILoot.isFromMain = false --标记是否是从首页过来，以判断返回键返回到哪里

local function btn_compoundAnimation(pack)
    local image_base_tab = UILoot.Widget:getChildByName("image_base_tab")
    local pageViewItem = pageView:getPage(pageView:getCurPageIndex())
    local ui_image = pageViewItem:getChildByName("image_good")
    local skillOrKungFuData =  utils.stringSplit(lootThing[LootDownFlag],"_")
    local dictSkillOrKungFuData = nil 
    local dictName = nil 
    local dictNum = pack.msgdata.int["1"]
    if LootFlag == 1 or LootFlag == 3 then 
        dictSkillOrKungFuData =DictMagic[tostring(skillOrKungFuData[1])]
    elseif LootFlag == 2 then
        dictSkillOrKungFuData =DictManualSkill[tostring(skillOrKungFuData[1])] --斗技字典表
    end
    dictName = dictSkillOrKungFuData.name
    local dictNum = pack.msgdata.int["1"]
    local function callbackFunc()
      UIManager.showToast(Lang.ui_loot1 .. dictName .. "】" .."X"..dictNum.. Lang.ui_loot2)
      UILoot.isFlush = true
      UILoot.setup()
      UIGuidePeople.isGuide(nil,UILoot)
    end
    local armature = ActionManager.getUIAnimation(31,callbackFunc)
    local pos =ui_image:getWorldPosition()
    local  dictUiData_big = DictUI[tostring(dictSkillOrKungFuData.bigUiId)] --资源字典表
    local imageName_big = "image/" .. dictUiData_big.fileName
    local image = ccs.Skin:create(imageName_big)
    armature:getBone("Layer28"):addDisplay(image,0)
    armature:getBone("Layer27"):addDisplay(image,0)
    armature:setPosition(UIManager.screenSize.width / 2, UIManager.screenSize.height / 2)
    armature:setLocalZOrder(10000)
    UILoot.Widget:addChild(armature)
end

local function netCallbackFunc(pack)
  if tonumber(pack.header) == StaticMsgRule.lootPiece then
      btn_compoundAnimation(pack)
  elseif tonumber(pack.header) == StaticMsgRule.oneKeyMerge then
      btn_compoundAnimation(pack)
  end
end

local function sendLootPieceData(_type,_instPlayerLootId,_skillOrKungFuId)
    local  sendData = {
      header = StaticMsgRule.lootPiece,
      msgdata = {
        int = {
          instPlayerLootId    = _instPlayerLootId ,
          skillOrKungFuId  = _skillOrKungFuId,
          type   = _type
        }
      }
    }
    UIManager.showLoading()
    netSendPackage(sendData, netCallbackFunc)
end

local function sendLootPieceOneData (_type,_instPlayerLootId,_skillOrKungFuid)
    local sendData ={
        header = StaticMsgRule.oneKeyMerge,
        msgdata = {
          int = {
             instPlayerLootId =_instPlayerLootId,
             skillOrKungFuId = _skillOrKungFuid,
             type = _type
          }
        }
    }
    UIManager.showLoading()
    netSendPackage(sendData,netCallbackFunc)
end
local function selectedBtnChange(flag)
    local btn_loot_gongfa = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_loot_gongfa")
    -- local btn_loot_skill = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_loot_skill")
    local btn_loot_treasure = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_loot_treasure") 
    if flag == 1 then 
        btn_loot_gongfa:loadTextureNormal("ui/yh_btn02.png")
        btn_loot_gongfa:getChildByName("text_loot_gongfa"):setTextColor(cc.c4b(51,25,4,255))
        -- btn_loot_skill:loadTextureNormal("ui/yh_btn01.png")
        -- btn_loot_skill:getChildByName("text_loot_skill"):setTextColor(cc.c4b(255,255,255,255))
        btn_loot_treasure:loadTextureNormal("ui/yh_btn01.png")
        btn_loot_treasure:getChildByName("text_loot_treasure"):setTextColor(cc.c4b(255,255,255,255))
    elseif  flag ==  2 then
        btn_loot_gongfa:loadTextureNormal("ui/yh_btn01.png")
        btn_loot_gongfa:getChildByName("text_loot_gongfa"):setTextColor(cc.c4b(255,255,255,255))
        -- btn_loot_skill:loadTextureNormal("ui/yh_btn02.png")
        -- btn_loot_skill:getChildByName("text_loot_skill"):setTextColor(cc.c4b(51,25,4,255))
        btn_loot_treasure:loadTextureNormal("ui/yh_btn01.png")
        btn_loot_treasure:getChildByName("text_loot_treasure"):setTextColor(cc.c4b(255,255,255,255))
    elseif flag == 3 then 
        btn_loot_gongfa:loadTextureNormal("ui/yh_btn01.png")
        btn_loot_gongfa:getChildByName("text_loot_gongfa"):setTextColor(cc.c4b(255,255,255,255))
        -- btn_loot_skill:loadTextureNormal("ui/yh_btn01.png")
        -- btn_loot_skill:getChildByName("text_loot_skill"):setTextColor(cc.c4b(255,255,255,255))
        btn_loot_treasure:loadTextureNormal("ui/yh_btn02.png")
        btn_loot_treasure:getChildByName("text_loot_treasure"):setTextColor(cc.c4b(51,25,4,255))
    end
end
---剪切碎片为86*86
local function addDownLayerChip(_imageName,_table_location,_table_chip,_image_frame,_image)
    for key,obj in pairs(_table_location) do
        local Position = utils.stringSplit(obj, ",")
        _image[key]:setVisible(true)
        local base_number = _image_frame[key]:getChildByName("image_base_number")
        base_number:setVisible(true)
        local number = 0 
        if net.InstPlayerChip then 
            for _key,_obj in pairs(net.InstPlayerChip) do
                if _obj.int["3"] == _table_chip[key].id then 
                    number = _obj.int["4"]
                end
            end
        end
            
        base_number:getChildByName("text_number"):setString(number)
        _image[key]:loadTexture(_imageName)
        local x1,y1,x2,y2 =0,0,86,86
        
        if Position[1]-43 > 0 then 
            x1 =Position[1]-43
        end
        if Position[2]-43 >0 then
            y1 =Position[2]-43
        end
        _image[key]:setTextureRect(cc.rect(x1,y1,x2,y2))
        local ui_panel = _image_frame[key]:getChildByName("panel")
        if number == 0 then 
            -----碎片不足 抢夺事件 --- 
            local function btnTouchEvent(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                         local param ={}
                         table.insert(param,_table_chip[key].id)
                         table.insert(param,_imageName)
                         table.insert(param,x1)
                         table.insert(param,y1)
                         UILootHint.setOperateType(UILootHint.operateType.chip,param)
                end
            end
            _image_frame[key]:setTouchEnabled(true)
            utils.GrayWidget(_image[key],true)
            _image_frame[key]:addTouchEventListener(btnTouchEvent)
            local param = {}
            param[1] = 2 
            param[2] = _image_frame[key]
            UIGuidePeople.isGuide(param,UILoot)
            local Particle1,Particle2= nil,nil
            if LootFlag == 1 then 
              Particle1 = cc.ParticleSystemQuad:create("particle/ui_anim_effect30.plist")
              Particle2 = cc.ParticleSystemQuad:create("particle/ui_anim_effect30.plist")
            elseif LootFlag == 2 then 
              Particle1 = cc.ParticleSystemQuad:create("particle/ui_anim_effect28.plist")
              Particle2 = cc.ParticleSystemQuad:create("particle/ui_anim_effect28.plist")
            elseif LootFlag == 3 then  
              Particle1 = cc.ParticleSystemQuad:create("particle/ui_anim_effect29.plist")
              Particle2 = cc.ParticleSystemQuad:create("particle/ui_anim_effect29.plist")
            end
            local size = ui_panel:getContentSize()
            local path1 = utils.MyPathFun(0,size.height,size.width,0.8,1)
            Particle1:setPosition(cc.p(0,0))
            ui_panel:addChild(Particle1,100,100)
            Particle1:runAction(path1)
            local path2 = utils.MyPathFun(0,size.height,size.width,0.8,2)
            Particle2:setPosition(cc.p(size.width,size.height))
            ui_panel:addChild(Particle2,101,101)
            Particle2:runAction(path2)
        else
          utils.GrayWidget(_image[key],false)
          _image_frame[key]:setTouchEnabled(false)
          
        end
    end
end

---更新下面的碎片界面
local function setPageViewItem(item, index)
    local ui_times = item:getChildByName("text_time_left_0")
    local ui_image_good = item:getChildByName("image_good")
    local ui_image_base_name = item:getChildByName("image_base_name")
    local ui_image_basemap =  item:getChildByName("image_basemap")
    if LootFlag == 1 then 
      ui_image_basemap:loadTexture("ui/qd_gongfa.png")
    elseif LootFlag == 2 then 
      ui_image_basemap:loadTexture("ui/qd_skill.png")
    else 
      ui_image_basemap:loadTexture("ui/qd_fabao.png")
    end
    local ui_image_frame_chip = {}
    for i=1,6 do
        ui_image_frame_chip[i] = item:getChildByName("image_frame_chip" .. i)
        ui_image_frame_chip[i]:getChildByName("image_base_number"):setVisible(false)
        ui_image_frame_chip[i]:getChildByName("image_chip" .. i):setVisible(false)
    end
    local dictGongFaorSkillData = nil
    local name = nil
    local KungFuorSkillData =  utils.stringSplit(lootThing[index],"_")
    local KungFuorSkillId,compoundTimes =KungFuorSkillData[1],KungFuorSkillData[2]
    if LootFlag == 1 or LootFlag == 3 then
        dictGongFaorSkillData = DictMagic[tostring(KungFuorSkillId)]
    else
        dictGongFaorSkillData = DictManualSkill[tostring(KungFuorSkillId)] --手动技能字典表
    end
    name = dictGongFaorSkillData.name
    ui_times:setString(Lang.ui_loot3 .. compoundTimes)
    local  dictUiData_big = DictUI[tostring(dictGongFaorSkillData.bigUiId)] --资源字典表
    local dictUiData_small = DictUI[tostring(dictGongFaorSkillData.smallUiId)]
    local imageName_small = "image/" .. dictUiData_small.fileName
    local imageName_big = "image/" .. dictUiData_big.fileName
    ui_image_good:loadTexture(imageName_big)
    local function getInfoEvent(sender,eventType)
      if eventType == ccui.TouchEventType.ended then
          if LootFlag == 2 then 
            UIBagSkillHint.setSkillInfo(dictGongFaorSkillData,UIBagSkillHint.operateType.skillInfo)
          elseif dictGongFaorSkillData.value1 ~= "3" then 
            UIGongfaInfo.setDictMagicId(dictGongFaorSkillData.id)
            UIManager.pushScene("ui_gongfa_info")
          end
      end
    end
    ui_image_good:setEnabled(true)
    ui_image_good:setTouchEnabled(true)
    ui_image_good:addTouchEventListener(getInfoEvent)
    local chops  =nil
    if LootFlag == 1 or LootFlag == 3 then 
        chops= DictMagic[tostring(KungFuorSkillId)].chops
    else 
        chops= DictManualSkill[tostring(KungFuorSkillId)].chops
    end
    local table_location = utils.stringSplit(chops, ";")
    ui_image_base_name:getChildByName("text_name"):setString(name)
    local table_chip = {}
    local image_frame = {}
    local image ={}
    for key ,obj in pairs(DictChip) do
        if LootFlag == 1 then --功法
            if obj.type == 2 and obj.skillOrKungFuId == tonumber(KungFuorSkillId) then 
                table.insert(table_chip,obj)
            end
        elseif  LootFlag == 3 then --法宝
            if obj.type == 3 and obj.skillOrKungFuId == tonumber(KungFuorSkillId) then 
                table.insert(table_chip,obj)
            end
        else
            if obj.type == 1 and obj.skillOrKungFuId == tonumber(KungFuorSkillId) then 
                table.insert(table_chip,obj)
            end
        end
    end
    if #table_location ~= #table_chip then 
      UIManager.showToast(name .. Lang.ui_loot4)
      return
    end
    if #table_location == 3 then
        ui_image_frame_chip[2]:setVisible(false)
        ui_image_frame_chip[4]:setVisible(false)
        ui_image_frame_chip[6]:setVisible(false)
        ui_image_frame_chip[1]:setVisible(true)
        ui_image_frame_chip[3]:setVisible(true)
        ui_image_frame_chip[5]:setVisible(true)
    elseif #table_location == 4 then 
        ui_image_frame_chip[2]:setVisible(true)
        ui_image_frame_chip[4]:setVisible(false)
        ui_image_frame_chip[6]:setVisible(true)
        ui_image_frame_chip[1]:setVisible(false)
        ui_image_frame_chip[3]:setVisible(true)
        ui_image_frame_chip[5]:setVisible(true)
    elseif #table_location == 6 then
        ui_image_frame_chip[2]:setVisible(true)
        ui_image_frame_chip[4]:setVisible(true)
        ui_image_frame_chip[6]:setVisible(true)
        ui_image_frame_chip[1]:setVisible(true)
        ui_image_frame_chip[3]:setVisible(true)
        ui_image_frame_chip[5]:setVisible(true)
    end
    for i=1,6 do
        if ui_image_frame_chip[i]:isVisible() then 
             table.insert(image,ui_image_frame_chip[i]:getChildByName("image_chip" .. i))
             table.insert(image_frame,ui_image_frame_chip[i])
        end
        for tag = 100,101 do 
            if ui_image_frame_chip[i]:getChildByName("panel"):getChildByTag(tag) then 
                ui_image_frame_chip[i]:getChildByName("panel"):removeChildByTag(tag)
            end
        end
    end
    addDownLayerChip(imageName_big,table_location,table_chip,image_frame,image)
end

local function scrollviewFocus( nt )
  local curPageIndex = pageView:getCurPageIndex()
  if nt then
    curPageIndex = LootDownFlag - 1
  end
  LootDownFlag =curPageIndex+1
  if ui_selectedFrame then
       ui_selectedFrame:removeFromParent()
  end
  local contaniner = scrollView:getInnerContainer()
  local item = scrollView:getChildByTag(curPageIndex+1)
  local w = (contaniner:getContentSize().width - scrollView:getContentSize().width)
  local dt
  if w == 0 then
    dt = 0
  else
    dt = (item:getPositionX() + item:getContentSize().width - scrollView:getContentSize().width) / w
    if dt < 0 then
      dt = 0
    end
  end
  scrollView:scrollToPercentHorizontal(dt * 100, 0.5, true)
  ui_selectedFrame:setPosition(cc.p(item:getContentSize().width/2,item:getContentSize().height/2))
  item:addChild(ui_selectedFrame)
end
local function setScrollViewItem(key,_chipItem, obj)
    if key == LootDownFlag then
        if ui_selectedFrame:getParent() then 
          ui_selectedFrame:removeFromParent()
        end
        ui_selectedFrame:setPosition(cc.p(_chipItem:getContentSize().width/2,_chipItem:getContentSize().height/2))
        _chipItem:addChild(ui_selectedFrame)
    end
    local ui_gfIcon = _chipItem:getChildByName("image_warior_four")
    if LootFlag == 1 or LootFlag == 3 then 
        local KungFuData =  utils.stringSplit(obj,"_")
        local kungFuId,compoundTimes =KungFuData[1],KungFuData[2]
        local dictMagicData = DictMagic[tostring(kungFuId)] --宝物字典表
        local dictUiData = DictUI[tostring(dictMagicData.smallUiId)] --资源字典表
        ui_gfIcon:loadTexture("image/" .. dictUiData.fileName)
        utils.addBorderImage(StaticTableType.DictMagic,kungFuId,_chipItem)
    elseif LootFlag == 2 then 
        local SkillData =  utils.stringSplit(obj,"_")
        local skillId,compoundTimes =SkillData[1],SkillData[2]
        local dictSkillData = DictManualSkill[tostring(skillId)] --手动技能字典表
        local dictUiData = DictUI[tostring(dictSkillData.smallUiId)] --资源字典表
        ui_gfIcon:loadTexture("image/" .. dictUiData.fileName)
        utils.addBorderImage(StaticTableType.DictManualSkill,skillId,_chipItem)
    end
    ----点击功法图标事件---
    local function btnItemFunc(sender,eventType)
          if eventType == ccui.TouchEventType.ended then
              scrollviewFocus()
              pageView:scrollToPage(key-1)
          end
     end
     _chipItem:addTouchEventListener(btnItemFunc)
    
end
local function scrollviewUpdate()
     for key, obj in pairs(lootThing) do
         local _chipItem = chipItem:clone()
         setScrollViewItem(key,_chipItem, obj)
         _chipItem:setTag(key)
         scrollView:addChild(_chipItem)
     end
end
function UILoot.stopSchedule()
       UILoot.countDownTime =0
       if UILoot.ScheduleId then 
         cc.Director:getInstance():getScheduler():unscheduleScriptEntry(UILoot.ScheduleId)
         UILoot.ScheduleId = nil
       end
       if UILootChoose.Widget then 
            ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_time_left"):setVisible(false)
       end
       if UILoot.Widget then 
         ui_text_time:setVisible(false)
         ui_text_time_left:setVisible(false) 
       end
end
function UILoot.updateTime()
  
    if UILoot.countDownTime ~= 0 then 
        UILoot.countDownTime  = UILoot.countDownTime -1
        local hour= math.floor(UILoot.countDownTime/3600)
        local min= math.floor(UILoot.countDownTime%3600/60)
        local sec= UILoot.countDownTime%60
        ui_text_time:setVisible(true)
        ui_text_time_left:setVisible(true)
        ui_text_time:setString(string.format("%02d:%02d:%02d",hour,min,sec))
        if  UILootChoose.Widget then 
            ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_time_left"):setVisible(true)
            ccui.Helper:seekNodeByName(UILootChoose.Widget, "text_time_left"):setString(string.format(Lang.ui_loot5,hour,min,sec))
        end
    else
       UILoot.stopSchedule()
    end
end

function UILoot.init()
    local btn_back = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_back") 
    local btn_compound = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_compound") ---合成
    local btn_compound_one = ccui.Helper:seekNodeByName(UILoot.Widget,"btn_compound_one") --一键合成
    local btn_loot_gongfa = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_loot_gongfa")
    -- local btn_loot_skill = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_loot_skill") -- 没有
    local btn_loot_treasure = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_loot_treasure")
    local btn_peace = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_peace")
    local btn_bag   = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_bag")
    btn_back:setPressedActionEnabled(true)
    btn_compound:setPressedActionEnabled(true)
    btn_compound_one:setPressedActionEnabled(true)
    btn_loot_treasure:setPressedActionEnabled(true)
    btn_bag:setPressedActionEnabled(true)
    ui_selectedFrame = ccui.ImageView:create("ui/frame_fg.png")
    -- 防止被image_di给覆盖了
    btn_bag:setLocalZOrder(1)
    btn_back:setLocalZOrder(1)

    positionY_one = btn_compound_one:getPositionY()
    positionY = btn_compound:getPositionY()
    local function btnTouchEvent(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if sender == btn_back then
              -- if UILoot.isFromMain then
              --   UILoot.isFromMain = false
                UIMenu.onHomepage()
              -- else
              --   -- UIMenu.onActivity()
              --   UIManager.showWidget("ui_activity_tower")
              -- end
            elseif  sender == btn_compound then 
                local ui_image_frame_chip = {}
                local btn_compound_flag =true
                local pageViewItem = pageView:getPage(pageView:getCurPageIndex())
                for i=1,6 do
                  ui_image_frame_chip[i] = pageViewItem:getChildByName("image_frame_chip" .. i)
                  if ui_image_frame_chip[i]:isVisible() then 
                    if tonumber(ccui.Helper:seekNodeByName(ui_image_frame_chip[i], "text_number"):getString()) == 0 then 
                      btn_compound_flag =false
                    end
                  end
                end
                if btn_compound_flag then 
                    local type = nil 
                    if LootFlag == 1 then 
                        type = 2
                    elseif LootFlag == 2 then
                        type = 1
                    elseif LootFlag == 3 then
                        type = 3
                    end
                    local Data =utils.stringSplit(lootThing[LootDownFlag],"_")
                    sendLootPieceData(type,instPlayerLootId,Data[1])
                else
                  UIManager.showToast(Lang.ui_loot6)
                end
            elseif sender ==  btn_peace then 
                UILootHint.setOperateType(UILootHint.operateType.peace,instPlayerLootId)
            elseif sender ==  btn_loot_gongfa then 
                if LootFlag == 1 then 
                    return
                end
                LootFlag =1 
                LootDownFlag = 1
                UILoot.setup()
            -- elseif sender ==  btn_loot_skill then 
            --     if LootFlag == 2 then 
            --         return
            --     end
            --     LootFlag =2
            --     LootDownFlag = 1
            --     UILoot.setup()
            elseif sender == btn_loot_treasure then 
                if LootFlag == 3 then 
                    return
                end
                LootFlag =3
                LootDownFlag = 1
                UILoot.setup()
            elseif sender == btn_bag then
              --xzli did it
              --[[
               local openLv = DictFunctionOpen[tostring(StaticFunctionOpen.fight)].level
                local lootOpen = false
                if net.InstPlayerBarrier then
                    for key, obj in pairs(net.InstPlayerBarrier) do
                        if obj.int["3"] == openLv then
                            lootOpen = true
                            break;
                        end
                    end
                end
                if lootOpen then
                    UIManager.showWidget("ui_team_info", "ui_bag_gongfa")
                else
                    UIManager.showToast(Lang.ui_homepage5 .. DictBarrier[tostring(openLv)].name)
                    return
                end
                ]]
                if LootFlag == 1 then
                  UIBagGongFa.setBagFlag(1)
                else
                  UIBagGongFa.setBagFlag(2)
                end
                UIManager.showWidget("ui_team_info", "ui_bag_gongfa")
            elseif sender == btn_compound_one then
                local ui_image_frame_chip = {}
                local btn_compound_flag =true
                local pageViewItem = pageView:getPage(pageView:getCurPageIndex())
                for i=1,6 do
                  ui_image_frame_chip[i] = pageViewItem:getChildByName("image_frame_chip" .. i)
                  if ui_image_frame_chip[i]:isVisible() then 
                    if tonumber(ccui.Helper:seekNodeByName(ui_image_frame_chip[i], "text_number"):getString()) == 0 then 
                      btn_compound_flag =false
                    end
                  end
                end
                if btn_compound_flag then 
                    local type = nil 
                    if LootFlag == 1 then 
                        type = 2
                    elseif LootFlag == 2 then
                        type = 1
                    elseif LootFlag == 3 then
                        type = 3
                    end
                    local Data =utils.stringSplit(lootThing[LootDownFlag],"_")
                    sendLootPieceOneData(type,instPlayerLootId,Data[1])
                else
                  UIManager.showToast(Lang.ui_loot7)
                end
            end
        end
    end

    btn_back:addTouchEventListener(btnTouchEvent)   
    btn_compound:addTouchEventListener(btnTouchEvent)
    btn_compound_one:addTouchEventListener(btnTouchEvent)
    btn_peace:addTouchEventListener(btnTouchEvent)
    btn_loot_gongfa:addTouchEventListener(btnTouchEvent)
    -- btn_loot_skill:addTouchEventListener(btnTouchEvent)
    btn_loot_treasure:addTouchEventListener(btnTouchEvent)
    btn_bag:addTouchEventListener(btnTouchEvent)

    scrollView = ccui.Helper:seekNodeByName(UILoot.Widget, "view_warrior")
    chipItem = scrollView:getChildByName("btn_base_chip"):clone()
    _pageView = ccui.Helper:seekNodeByName(UILoot.Widget, "view_all"):clone()
    pageViewItem = _pageView:getChildByName("panel_all"):clone()
    _pageView:removeAllPages()
    ccui.Helper:seekNodeByName(UILoot.Widget, "view_all"):removeFromParent()
    ui_text_time_left = ccui.Helper:seekNodeByName(UILoot.Widget, "text_time_left")
    ui_text_time = ccui.Helper:seekNodeByName(UILoot.Widget, "text_time")
    ui_text_time_left:setVisible(false)
    ui_text_time:setVisible(false)

end
function UILoot.setup()
    if net.InstPlayerLoot then 
        for key, obj in pairs(net.InstPlayerLoot) do
            instPlayerLootId = obj.int["1"]
            if next(obj) and obj.string["3"] ~= "" and obj.string["3"] ~= "0" then 
                local currentTime = utils.getCurrentTime()
                local endTime = utils.GetTimeByDate(obj.string["3"])
                UILoot.countDownTime = endTime - currentTime
            end
        end
    end
    
    if UILoot.countDownTime > 0 then 
       if not UILoot.ScheduleId then 
         local hour= math.floor(UILoot.countDownTime/3600)
         local min= math.floor(UILoot.countDownTime%3600/60)
         local sec= UILoot.countDownTime%60
         ui_text_time:setString(string.format("%02d:%02d:%02d",hour,min,sec))
         ui_text_time:setVisible(true)
         ui_text_time_left:setVisible(true)
         UILoot.ScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(UILoot.updateTime,1,false)
       end
    else 
      UILoot.stopSchedule()
    end
    UIGuidePeople.isGuide(1,UILoot) 
    if chipItem:getReferenceCount() == 1 then
      chipItem:retain()
    end
    if ui_selectedFrame:getReferenceCount() == 1 then
      ui_selectedFrame:retain()
    end
    if pageViewItem:getReferenceCount() == 1 then
      pageViewItem:retain()
    end
    if _pageView:getReferenceCount() == 1 then
      _pageView:retain()
    end
    if not UILoot.isFlush then 
      if pageView then 
        pageView:removeFromParent()
        pageView = nil
      end
      pageView = _pageView:clone()
      UILoot.Widget:addChild(pageView)
    else 
      UILoot.isFlush = nil
      pageView:removeAllPages()
    end
    scrollView:jumpToLeft()
    scrollView:removeAllChildren()
    local ui_label_fight = ccui.Helper:seekNodeByName(UILoot.Widget, "label_fight") 
    local ui_endurance = ccui.Helper:seekNodeByName(UILoot.Widget, "text_endurance_number")
    local ui_gold = ccui.Helper:seekNodeByName(UILoot.Widget, "text_gold_number") 
    local ui_silver = ccui.Helper:seekNodeByName(UILoot.Widget, "text_silver_number")  
    local btn_compound = ccui.Helper:seekNodeByName(UILoot.Widget, "btn_compound")
    local btn_compound_one =ccui.Helper:seekNodeByName(UILoot.Widget,"btn_compound_one")
    local text_hint_vip = ccui.Helper:seekNodeByName(UILoot.Widget,"text_hint")
    selectedBtnChange(LootFlag)
    ui_label_fight:setString(utils.getFightValue()) 
    ui_endurance:setString(net.InstPlayer.int["10"] .. "/" .. net.InstPlayer.int["11"])
    ui_gold:setString(tostring(net.InstPlayer.int["5"]))
    ui_silver:setString(net.InstPlayer.string["6"])
    lootThing ={}
    local openLv = DictSysConfig[tostring(StaticSysConfig.MagicAutoLevel)].value
    local openVip = DictSysConfig[tostring(StaticSysConfig.MagicAutoVip)].value
    if net.InstPlayer.int["4"]< openLv then
        btn_compound_one:setVisible(false)
        text_hint_vip:setVisible(false)
        btn_compound:setPositionY( positionY + 5 )
    else
        btn_compound_one:setVisible(true)
        text_hint_vip:setVisible(true)
        if net.InstPlayer.int["19"] < openVip then
            btn_compound_one:setBright(false)
            btn_compound_one:setTouchEnabled(false)
            btn_compound_one:setPositionY( positionY_one )
            btn_compound:setPositionY( positionY )
        else
            btn_compound_one:setBright(true)
            text_hint_vip:setVisible(false)
            btn_compound_one:setPositionY( positionY_one + 5 )
            btn_compound:setPositionY( positionY + 5 )
            btn_compound_one:setTouchEnabled(true)
        end
    end
    if net.InstPlayerLoot then
        if LootFlag == 1 then 
            for key, obj in pairs(net.InstPlayerLoot) do
              if obj.string["5"] ~="" and obj.string["5"] ~= nil then 
                 lootThing = utils.stringSplit(obj.string["5"],";")
              end
            end
            if next(lootThing) then 
                  local function compare(value1,value2) --此处是为了将引导的功法放在第一个位置
                      local obj_1 =  utils.stringSplit(value1,"_")
                      local obj_2 =  utils.stringSplit(value2,"_")
                      if tonumber(obj_1[1]) == 27 and tonumber(obj_2[1]) ~= 27 then 
                          return false
                      elseif  tonumber(obj_1[1]) ~= 27 and tonumber(obj_2[1]) == 27 then 
                          return true
                      elseif DictMagic[ tostring( obj_1[1] ) ].magicQualityId < DictMagic[ tostring( obj_2[1] ) ].magicQualityId then
                          return true
                      elseif DictMagic[ tostring( obj_1[1] ) ].magicQualityId > DictMagic[ tostring( obj_2[1] ) ].magicQualityId then
                          return false
                      else 
                          if tonumber(obj_1[1]) > tonumber(obj_2[1]) then 
                            return true
                          else
                            return false
                          end
                      end 
                  end
            
              utils.quickSort(lootThing,compare)
            end
        elseif LootFlag == 2 then 
            for key, obj in pairs(net.InstPlayerLoot) do
              if obj.string["4"] ~= "" and obj.string["4"] ~= nil then 
                 lootThing = utils.stringSplit(obj.string["4"],";")
              end
            end
        elseif LootFlag == 3 then 
            for key, obj in pairs(net.InstPlayerLoot) do
              if obj.string["6"] ~= "" and obj.string["6"] ~= nil then 
                 lootThing = utils.stringSplit(obj.string["6"],";")
              end
            end
            if next(lootThing) then 
              local function compare(value1,value2) --此处是为了将引导的法宝放在第一个位置
                  local obj_1 =  utils.stringSplit(value1,"_")
                  local obj_2 =  utils.stringSplit(value2,"_")
                  if tonumber(obj_1[1]) == 16 and tonumber(obj_2[1]) ~= 16 then 
                      return false
                  elseif  tonumber(obj_1[1]) ~= 16 and tonumber(obj_2[1]) == 16 then 
                      return true
                   elseif DictMagic[ tostring( obj_1[1] ) ].magicQualityId < DictMagic[ tostring( obj_2[1] ) ].magicQualityId then
                      return true
                  elseif DictMagic[ tostring( obj_1[1] ) ].magicQualityId > DictMagic[ tostring( obj_2[1] ) ].magicQualityId then
                      return false
                  else 
                      if tonumber(obj_1[1]) > tonumber(obj_2[1]) then 
                        return true
                      else
                        return false
                      end
                  end 
              end
              utils.quickSort(lootThing,compare)
            end
        end
    end
     local function pageViewEvent(sender, eventType)
      if eventType == ccui.PageViewEventType.turning  then
        if LootDownFlag - 1 ~= pageView:getCurPageIndex() then 
          scrollviewFocus()
        end
      end
    end

    if next(lootThing) then
        local nt = false 
        if LootDownFlag > #lootThing then --防止被合成的是最后一个碎片
          LootDownFlag = #lootThing
          nt = true
        end
          scrollviewUpdate()
          local innerWidth= 0
          local childs = scrollView:getChildren()
          innerWidth = (chipItem:getContentSize().width) * #childs
          if innerWidth < scrollView:getContentSize().width then
              innerWidth = scrollView:getContentSize().width
          end
                scrollView:setInnerContainerSize(cc.size(innerWidth,scrollView:getContentSize().height))
                local x,y = 0,scrollView:getContentSize().height/2
                for i=1,#childs do
                     x= (chipItem:getContentSize().width/2  + (i-1)*(chipItem:getContentSize().width))
                     childs[i]:setPosition(cc.p(x,y))
                     local _pvItem = pageViewItem:clone()
                     pageView:addPage(_pvItem)
                     setPageViewItem(_pvItem,i)
                end 
                -- pageView:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                -- pageView:scrollToPage(LootDownFlag-1)
                -- end)))
                btn_compound:setBright(true)
                btn_compound:setEnabled(true)
                UIGuidePeople.isGuide(btn_compound,UILoot) 
                 pageView:addEventListener(pageViewEvent)
                scrollviewFocus( nt )
                UILoot.isLoot = nil
    else
        local item = pageViewItem:clone()
        pageView:addPage(item)
        local ui_times = item:getChildByName("text_time_left_0")
        local ui_image_good = item:getChildByName("image_good")
        local ui_image_base_name = item:getChildByName("image_base_name")
        local ui_image_basemap =  item:getChildByName("image_basemap")
        local ui_image_frame_chip = {}
        for i=1,6 do
            ui_image_frame_chip[i] = item:getChildByName("image_frame_chip" .. i)
            ui_image_frame_chip[i]:getChildByName("image_base_number"):setVisible(false)
            ui_image_frame_chip[i]:getChildByName("image_chip" .. i):setVisible(false)
        end
        ui_times:setVisible(false)
        ui_image_good:setVisible(false)
        ui_image_base_name:setVisible(false)
        btn_compound:setBright(false)
        btn_compound:setEnabled(false)
        pageView:addEventListener(pageViewEvent)
        scrollviewFocus()
        UILoot.isLoot = nil
    end 
   
   
end

function UILoot.show(upflag,downFlag)
    LootFlag =upflag
    LootDownFlag = downFlag
    UIManager.showWidget("ui_loot")
end

function UILoot.setTimeInterval(intervalTime)
    local countDownTime =  UILoot.countDownTime- intervalTime
    if countDownTime > 0 then 
        UILoot.countDownTime = countDownTime
    else
        UILoot.stopSchedule()
    end
end

function UILoot.free( ... )
  if pageView and not UILoot.isLoot then 
    pageView:removeFromParent()
    pageView = nil
  end
  scrollView:removeAllChildren()
end
