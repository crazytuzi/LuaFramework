--[[ 问卷调查 ]]--
local Questionnaire = class("Questionnaire", function() return cc.Layer:create() end )
local questionDB = require("src/config/QuestionDb")

function Questionnaire:ctor( params )
    local idx = params.index or 1
    local bg = createSprite(self, "res/common/bg/bg56.png", cc.p(display.cx, display.cy))
    createSprite(bg,"res/layers/activity/cell/question/title.png", cc.p(500, 573))
    local closeFun = function()
        removeFromParent(self)
    end
    createTouchItem(bg,"res/component/button/X.png",cc.p(920,573),closeFun)

    local url = questionDB[1].q_url
    for i=1, #questionDB do
        if tonumber(questionDB[i].q_id) == idx and questionDB[i].q_url then
            url = questionDB[i].q_url
            break
        end
    end
    print("[Questionnaire] .. idx " .. idx .. ",url" .. url)

    if Device_target ~= cc.PLATFORM_OS_WINDOWS then
        self._webView = ccexp.WebView:create()
        self._webView:setPosition(67, 60)
        self._webView:setAnchorPoint(cc.p(0,0))
        self._webView:setContentSize(824, 485)
        self._webView:loadURL(url)
        self._webView:setScalesPageToFit(true)

        self._webView:setOnShouldStartLoading(function(sender, url)
            print("onWebViewShouldStartLoading, url is ", url)
            return true
        end)
        self._webView:setOnDidFinishLoading(function(sender, url)
            print("onWebViewDidFinishLoading, url is ", url)
        end)
        self._webView:setOnDidFailLoading(function(sender, url)
            print("setOnDidFailLoading, url is ", url)
        end)

        bg:addChild(self._webView, 1000)
    end
    -- local colorbg = cc.LayerColor:create(cc.c4b(0, 0, 0, 175))
    -- bg:addChild(colorbg)
    -- colorbg:setPosition(67, 60)
    -- colorbg:setContentSize(824,  485)

    self:setLocalQuestionRecord(idx, idx <= 100)
    SwallowTouches(self)
end

function Questionnaire:checkLocalRecord(lv)
    local index = getLocalRecordByKey(1, userInfo.currRoleStaticId .. "SpeclastQuestion", -1)
    local currentQuestionIndex = index
    local isFindeIndex = false
    for i=1, #questionDB do
        if tonumber(questionDB[i].q_id) <= 100 then
            if tonumber(lv) >= tonumber(questionDB[i].q_lev) and tonumber(questionDB[i].q_id) > index then
                currentQuestionIndex = tonumber(questionDB[i].q_id)
                Questionnaire:createMainSceneIcon(currentQuestionIndex)
                isFindeIndex = true
                break
            end 
        else
            break
        end
    end    

    if isFindeIndex then
        return
    end

    local index = getLocalRecordByKey(1, userInfo.currRoleStaticId .. "lastQuestion", -1)
    currentQuestionIndex = index
    for i=1, #questionDB do
        if tonumber(lv) >= tonumber(questionDB[i].q_lev) and tonumber(questionDB[i].q_id) > index then
            currentQuestionIndex = tonumber(questionDB[i].q_id)
            Questionnaire:createMainSceneIcon(currentQuestionIndex)
            break
        end 
    end
end

function Questionnaire:setLocalQuestionRecord(index, isSpec)
    if isSpec then
        setLocalRecordByKey(1, userInfo.currRoleStaticId .. "SpeclastQuestion", tonumber(index))
    else
        setLocalRecordByKey(1, userInfo.currRoleStaticId .. "lastQuestion", tonumber(index))
    end
end

function Questionnaire:createMainSceneIcon(QuestionIndex)
    if true then return end
    print("createMainSceneIcon..QuestionIndex" .. QuestionIndex)
    local iconRemoveFunc = function()
        if G_MAINSCENE and G_MAINSCENE.IconBtn then
            removeFromParent(G_MAINSCENE.IconBtn)
            G_MAINSCENE.IconBtn = nil
        end
    end

    local quesInfo = getConfigItemByKey("QuestionDb", "q_id", QuestionIndex)
    --dump(quesInfo)
    if G_ROLE_MAIN and quesInfo and G_MAINSCENE then
        local buttonFunc = function()
            iconRemoveFunc()
            local sub_node = require("src/layers/activity/Questionnaire").new( { index = QuestionIndex} )
            G_MAINSCENE:addChild(sub_node, 1000)            
        end

        iconRemoveFunc()
        local node = cc.Node:create()
        local button = createMenuItem(node, "res/mainui/yjdc.png", cc.p( display.cx - 70 , 150 ), buttonFunc)
        G_MAINSCENE:addChild(node, 100)
        performWithNoticeAction(button)

        G_MAINSCENE.IconBtn = button
        --performWithDelay(G_MAINSCENE, function() iconRemoveFunc() end, 30)
    end    
end

return Questionnaire