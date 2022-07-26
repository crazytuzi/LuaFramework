require"Lang"
UIGemList={}

UIGemList.OperateType = {
	GemInlay = 1, --镶嵌
	GemUpgrade = 2, --升级
	GemSwithch = 3 --转换
}

local scrollView= nil
local listItem = nil 
local gemThing={}
local flag = nil
local uiItem= nil
local inlayThingId = nil
local function compare(value1,value2)
    if UIGuidePeople.levelStep then 
        if value1.int["3"] ~= 13 and value2.int["3"] == 13 then 
            return true 
        elseif value1.int["3"] == 13 and value2.int["3"] ~= 13 then   
            return false
        else 
            return value1.int["8"] > value2.int["8"]
        end
    else 
        return value1.int["8"] > value2.int["8"]
    end
end
local function setScrollViewItem(_Item, _obj)
    local image_frame= _Item:getChildByName("image_frame_gem")
    local image = image_frame:getChildByName("image_gem")
    local count = ccui.Helper:seekNodeByName(image_frame, "text_number")
    local name = _Item:getChildByName("text_gem_name")
    local text_property_gem = ccui.Helper:seekNodeByName(_Item,"text_property_gem")
    local btn_inlay = _Item:getChildByName("btn_inlay")
    local name_text=DictThing[tostring(_obj.int["3"])].name
    local smallUiId = DictThing[tostring(_obj.int["3"])].smallUiId
    local smallImage= DictUI[tostring(smallUiId)].fileName
    local propertyValue = DictThing[tostring(_obj.int["3"])].fightPropValue
    local fightPropId = DictThing[tostring(_obj.int["3"])].fightPropId
    local propertyName = DictFightProp[tostring(fightPropId)].name
    image_frame:loadTexture(utils.getThingQualityImg(DictThing[tostring(_obj.int["3"])].bkGround))
    image:loadTexture("image/" .. smallImage)
    name:setString(name_text)
    count:setString(tostring(_obj.int["5"]))
    text_property_gem:setString(Lang.ui_gem_list1 .. propertyValue .. Lang.ui_gem_list2 .. propertyName)
    btn_inlay:setPressedActionEnabled(true)
    local function  Btn_Event(sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
            if flag == UIGemList.OperateType.GemInlay then
            	uiItem(_obj.int["1"])
                btn_inlay:setEnabled(false)
            elseif flag == 2 then 
                UIGemUpGrade.setData(_obj,uiItem)
                UIGemUpGrade.setup()
                UIManager.popScene()
            elseif flag ==3 then 
                UIGemSwitch.setData(_obj,uiItem)
                UIGemSwitch.setup()
                UIManager.popScene()
            end
        end
    end
    if flag == UIGemList.OperateType.GemInlay then
    	btn_inlay:setTitleText(Lang.ui_gem_list3)
        if _Item:getTag() == 1 then 
            UIGuidePeople.isGuide(btn_inlay,UIGemList)
        end
    elseif flag == 2 then
        btn_inlay:setTitleText(Lang.ui_gem_list4)
    elseif flag == 3 then 
        btn_inlay:setTitleText(Lang.ui_gem_list5)
    end
    btn_inlay:addTouchEventListener(Btn_Event)
end
local function scrollviewUpdate()
    for key, obj in pairs(gemThing) do
         local gemItem = listItem:clone()
         setScrollViewItem(gemItem, obj)
         scrollView:addChild(gemItem)
     end
end
function UIGemList.init()
    local btn_close = ccui.Helper:seekNodeByName(UIGemList.Widget,"btn_close")
    local function closeEvent(sender,eventType)
        if eventType == ccui.TouchEventType.ended then 
            AudioEngine.playEffect("sound/button.mp3")
            UIManager.popScene()
        end
    end
    btn_close:addTouchEventListener(closeEvent)
    scrollView = ccui.Helper:seekNodeByName(UIGemList.Widget,"view_gem_list") 
    listItem = scrollView:getChildByName("image_base_gem"):clone()
    if listItem:getReferenceCount() == 1 then 
        listItem:retain()
    end
end

local function isContain(_dictThingId)
    if inlayThingId then
        for key, obj in pairs(inlayThingId) do
            if obj[2] == _dictThingId or (obj[2] > 0 and DictThing[tostring(obj[2])].fightPropId == DictThing[tostring(_dictThingId)].fightPropId) then
                return true
            end
        end
    end
end

function UIGemList.setup()
    
    scrollView:removeAllChildren()
    gemThing={}
    for key, obj in pairs(net.InstPlayerThing) do
        if obj.int["7"] == StaticBag_Type.core then
            if flag == UIGemList.OperateType.GemInlay then
                if not isContain(obj.int["3"]) then
                    table.insert(gemThing,obj)
                end
            else
                table.insert(gemThing,obj)
            end
        end
     end
     utils.quickSort(gemThing,compare)
     if gemThing then
        scrollView:jumpToTop()
        utils.updateView(UIGemList,scrollView,listItem,gemThing,setScrollViewItem)
     end
end

function UIGemList.setData(_flag,_uiItem,_inlayThingId)
    flag = _flag
    uiItem = _uiItem
    inlayThingId = _inlayThingId
end

function UIGemList.free()
    if listItem and listItem:getReferenceCount() >= 1 then 
        listItem:release()
        listItem = nil
    end
    if scrollView then
        scrollView:removeAllChildren()
        scrollView = nil
    end
end
