--
-- Created by IntelliJ IDEA.
-- User: douzi
-- Date: 14-8-12
-- Time: 下午6:11
-- To change this template use File | Settings | File Templates.
--

local ServerChooseLayer = class("ServerChooseLayer", function()
    return require("utility.ShadeLayer").new()
end)



local ServerNameItem = class("ServerNameItem", function(param)
    local proxy = CCBProxy:create()
    local rootnode = {}
    local node
    if param.type then
        if param.type == 1 then
            node = CCBuilderReaderLoad("login/login_server_name_1.ccbi", proxy, rootnode)
        else
            node = CCBuilderReaderLoad("login/login_server_name_2.ccbi", proxy, rootnode)
        end
    else
        node = CCBuilderReaderLoad("login/login_server_name.ccbi", proxy, rootnode)
    end
    node._rootnode = rootnode
    return node
end)

function ServerNameItem:ctor(param)
    local _info = param.info
    if _info then
        for k, v in ipairs(_info) do
            self._rootnode["nameNode_" ..  tostring(k)]:setVisible(true)
            self._rootnode["serverStat_" ..tostring(k)]:setDisplayFrame(display.newSpriteFrame(string.format("login_state_%d.png", v.status)))
            self._rootnode["serverNameLabel_" ..tostring(k)]:setString(v.name)
        end
    end
end

function ServerChooseLayer:ctor(serverList, callback)
    dump(serverList)

    local proxy = CCBProxy:create()
    self._rootnode = {}
    local contentNode = CCBuilderReaderLoad("login/login_server_choose.ccbi", proxy, self._rootnode)
    contentNode:setPosition(display.cx, display.cy + 30)
    self:addChild(contentNode, 1)

    local height = self._rootnode["listLayer"]:getContentSize().height
    local width = self._rootnode["listLayer"]:getContentSize().width
    local itemNum = math.ceil(#serverList / 2) + 1

    if height < itemNum * 70 then
        self._rootnode["listLayer"]:setContentSize(CCSizeMake(width, itemNum * 70))
        self._rootnode["scrollView"]:updateInset()
        self._rootnode["scrollView"]:setContentOffset(CCPointMake(0, height - itemNum * 70), false)
        height = itemNum * 70
    end

    local nodes = {}
    local node = ServerNameItem.new({
        type = 2
    })
    node:setPosition(width / 2, height)
    self._rootnode["listLayer"]:addChild(node)
    height = height - node:getContentSize().height

    for i = 1, #serverList, 2 do

        local t = {}
        if serverList[i] then
            table.insert(t, serverList[i])
        end

        if serverList[i + 1] then
            table.insert(t, serverList[i + 1])
        end

        node = ServerNameItem.new({
            info = t
        })
        self._rootnode["listLayer"]:addChild(node)
        node:setPosition(width / 2, height)
        height = height - node:getContentSize().height

        table.insert(nodes, node)
    end

    local bTouch
    local function onTouchMove(event)
        if math.abs(event.y - event.prevY) > 5 then
            bTouch = false
        end
    end

    local index = 1


    local function onSelectedServer()
--        dump(serverList[index])
        if callback then
            callback(index)
        end
        self:removeSelf()
    end

    self._rootnode["closeBtn"]:addHandleOfControlEvent(function()
        if callback then
            callback()
        end
        self:removeSelf()
    end, CCControlEventTouchDown)

    local function onTouchEnded(event)
        if bTouch then
            for k, v in ipairs(nodes) do
                local pos = v:convertToNodeSpace(ccp(event.x, event.y))
                if CCRectMake(0, 0, v:getContentSize().width, v:getContentSize().height):containsPoint(pos) then
                    local i
                    if pos.x > v:getContentSize().width / 2 then
                        i = 2
                    else
                        i = 1
                    end
                    index = (k - 1) * 2 + i
                    onSelectedServer()
                    break
                end
            end
        end
    end

    self._rootnode["serverNameNode"]:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function(event)
        if event.name == "began" then
            bTouch = true
            return true
        elseif event.name == "moved" then
            onTouchMove(event)
        elseif event.name == "ended" then
            onTouchEnded(event)
        end
    end)
end

return ServerChooseLayer

