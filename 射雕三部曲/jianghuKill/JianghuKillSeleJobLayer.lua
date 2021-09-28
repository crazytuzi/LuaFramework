--[[
    文件名: JianghuKillSeleJobLayer.lua
    描述: 江湖杀任务界面
    创建人: yanghongsheng
    创建时间: 2018.09.06
-- ]]
local JianghuKillSeleJobLayer = class("JianghuKillSeleJobLayer", function(params)
	return display.newLayer()
end)

--[[
	params:
		jobId     -- 默认选择职业id(默认1)
        callback  -- 刷新主界面回调
        isFirst   -- 是否第一次选职业，第一次必选不可返回
        isLook    -- 是否只是查看职业，不能选择
]]

function JianghuKillSeleJobLayer:ctor(params)
    self.mOldId = params.jobId
	self.mJobId = self.mOldId or 1
    self.mCallback = params.callback
    self.mIsFirst = params.isFirst or false
    self.mIsLook = params.isLook or false
	
	-- 弹窗
    local parentLayer = require("commonLayer.PopBgLayer").new({
    	bgSize = cc.size(640, 910),
        closeImg = self.mIsFirst and "" or "c_29.png",
    	title = TR("选择职业"),
    })
    self:addChild(parentLayer)

    -- 保存弹框控件信息
    self.mBgSprite = parentLayer.mBgSprite
    self.mBgSize = self.mBgSprite:getContentSize()

	self:requestInfo()
end

-- 初始化
function JianghuKillSeleJobLayer:initUI()
    -- 职业切换按钮
    self:createJobBtn()
    -- 职业克制
    self:createJobRestraint()

    -- 确认按钮
    if not self.mIsLook then
        local okBtn = ui.newButton({
                normalImage = "c_28.png",
                text = TR("确认"),
                clickAction = function ()
                    if self.mOldId and self.mOldId == self.mJobId then
                        LayerManager.removeLayer(self)
                    else
                        self:requestSelectJob()
                    end
                end,
            })
        okBtn:setPosition(self.mBgSize.width*0.5, 65)
        self.mBgSprite:addChild(okBtn)
    end

    -- 提示语
    local hintLabel = ui.newLabel({
            text = TR("选择人数较少的职业，获得高排名的机会更大"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    hintLabel:setPosition(self.mBgSize.width*0.5, 520)
    self.mBgSprite:addChild(hintLabel)
end

-- 职业按钮列表
function JianghuKillSeleJobLayer:createJobBtn()
    -- 职业按钮配置
    local jobBtnList = {
        [1] = {     -- 豪杰
            jobId = 1,
            normalImage = "jhs_49.png",
            position = cc.p(175, 775),
        },
        [2] = {     -- 刺客
            jobId = 2,
            normalImage = "jhs_48.png",
            position = cc.p(470, 775),
        },
        [3] = {     -- 书生
            jobId = 3,
            normalImage = "jhs_50.png",
            position = cc.p(175, 620),
        },
        [4] = {     -- 镖师
            jobId = 4,
            normalImage = "jhs_51.png",
            position = cc.p(470, 620),
        },
    }

    -- 创建职业按钮
    for _, btnInfo in ipairs(jobBtnList) do
        btnInfo.clickAction = function (jobBtn)
            if self.beforeSeleSprite then
                self.beforeSeleSprite:setVisible(false)
            end
            if self.beforeBtn then
                self.beforeBtn:setColor(cc.c3b(0x5f, 0x5f, 0x5f))
            end

            self.beforeSeleSprite = jobBtn.seleSprite
            self.beforeSeleSprite:setVisible(true)

            self.beforeBtn = jobBtn
            self.beforeBtn:setColor(cc.c3b(0xff, 0xf8, 0xea))

            self.mJobId = btnInfo.jobId

            self:refreshJobDesc(btnInfo.jobId)
        end

        local tempBtn = ui.newButton(btnInfo)
        tempBtn:setColor(cc.c3b(0x5f, 0x5f, 0x5f))
        self.mBgSprite:addChild(tempBtn)

        tempBtn.seleSprite = ui.newScale9Sprite("jhs_38.png", cc.size(292, 150))
        tempBtn.seleSprite:setVisible(false)
        tempBtn:getExtendNode2():addChild(tempBtn.seleSprite)

        if self.mJobId == btnInfo.jobId then
            tempBtn.mClickAction(tempBtn)
            if not self.mIsFirst then
                -- 添加当前职业标识
                local curSprite = ui.newSprite("jhs_121.png")
                curSprite:setPosition(110, -45)
                tempBtn:getExtendNode2():addChild(curSprite)
            end
        end

        -- 添加当前职业选择比例
        if self.mJobRatio then
            local jobRatioLabel = ui.newLabel({
                    text = self.mJobRatio[tostring(btnInfo.jobId)] and TR("%d%%选择", self.keepTwoDecimalPlaces(self.mJobRatio[tostring(btnInfo.jobId)])) or "",
                    color = cc.c3b(255, 231, 72),
                    size = 20,
                    outlineColor = cc.c3b(0x46, 0x22, 0x0d),
                })
            jobRatioLabel:setAnchorPoint(cc.p(1, 0.5))
            jobRatioLabel:setPosition(130, 45)
            tempBtn:getExtendNode2():addChild(jobRatioLabel)
        end
    end
end

-- 四舍五入
function JianghuKillSeleJobLayer.keepTwoDecimalPlaces(decimal)
        if decimal % 1 >= 0.5 then 
                decimal=math.ceil(decimal)
        else
                decimal=math.floor(decimal)
        end
        return  decimal
end

-- 创建职业克制
function JianghuKillSeleJobLayer:createJobRestraint()
    -- 背景
    if not self.restraintBg then
        local bgSprie = ui.newScale9Sprite("jhs_41.png", cc.size(580, 170))
        bgSprie:setPosition(self.mBgSize.width*0.5, 410)
        self.mBgSprite:addChild(bgSprie)
        self.restraintBg = bgSprie
    end
    self.restraintBg:removeAllChildren()
    -- 克制职业图标
    local jobTbList = {
        "jhs_71.png",
        "jhs_72.png",
        "jhs_73.png",
    }
    local jobPosList = self:PolygonsPoints(#jobTbList, cc.p(100, 75), 60)
    for i, jobTexture in ipairs(jobTbList) do
        -- 职业图标
        local jobSprite = ui.newSprite(jobTexture)
        jobSprite:setPosition(jobPosList[i])
        jobSprite:setScale(0.7)
        self.restraintBg:addChild(jobSprite)

        local orginAngle = 0                        -- 箭头初始角度
        local curPos = jobPosList[i]                -- 图标坐标
        local nextIndex = (i%(#jobTbList)) + 1      -- 下一个图标索引
        local nextPos = jobPosList[nextIndex]       -- 下一个图标坐标
        local midPos = cc.pMidpoint(curPos, nextPos)-- 中间的坐标
        local vectorPos = cc.pSub(curPos, nextPos)  -- 两点的向量
        local angle = cc.pToAngleSelf(vectorPos)    -- 向量转为弧度
        local angle = -angle*180/math.pi+orginAngle -- 弧度转角度
        -- 创建箭头
        local arrowSprite = ui.newSprite("jhs_52.png")
        arrowSprite:setPosition(midPos.x, midPos.y)
        self.restraintBg:addChild(arrowSprite)
        arrowSprite:setRotation(angle)
    end
    -- 不克制图标
    local jobSprite = ui.newSprite("jhs_74.png")
    jobSprite:setScale(0.7)
    jobSprite:setPosition(205, 108)
    self.restraintBg:addChild(jobSprite)

    -- 描述
    local titleLabel = ui.newLabel({
            text = TR("职业克制"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    titleLabel:setPosition(400, 130)
    self.restraintBg:addChild(titleLabel)

    local descLabel = ui.newLabel({
            text = TR("攻击克制的职业有攻击加成"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    descLabel:setPosition(400, 75)
    self.restraintBg:addChild(descLabel)
end

--[[
    描述：计算正多边形各个点坐标
    参数：num      边数
         centerPos  中心坐标
         radius     圆半径
]]
function JianghuKillSeleJobLayer:PolygonsPoints(num, centerPos, radius)
    local points = {}

    if num < 3 then
        return points
    end

    local angle = 2 * math.pi / num     -- 外夹角弧度
    local theta = math.pi / 2 + (num + 1) % 2 * angle / 2   -- 起始位置弧度

    -- 循环计算各个位置
    for i = 1, num do
        -- 计算位置
        local X = centerPos.x + radius * math.cos(theta)
        local Y = centerPos.y + radius * math.sin(theta)

        -- 加入列表
        local tempPoint = {x = X, y = Y}
        table.insert(points, tempPoint)

        -- 下一个位置弧度
        theta = theta - angle
    end

    return points
end

-- 刷新职业描述
function JianghuKillSeleJobLayer:refreshJobDesc(jobId)
    -- 背景
    if not self.jobDescBg then
        local bgSprie = ui.newScale9Sprite("jhs_41.png", cc.size(580, 200))
        bgSprie:setPosition(self.mBgSize.width*0.5, 205)
        self.mBgSprite:addChild(bgSprie)
        self.jobDescBg = bgSprie
    end
    self.jobDescBg:removeAllChildren()

    local jobConfig = self:getJobConfig(jobId)
    -- 职业图标
    local jobSprite = ui.newSprite(jobConfig.jobTexture)
    jobSprite:setPosition(50, 80)
    self.jobDescBg:addChild(jobSprite)

    -- 描述
    local titleLabel = ui.newLabel({
            text = TR("职业特性"),
            color = cc.c3b(0x46, 0x22, 0x0d),
        })
    titleLabel:setPosition(295, 165)
    self.jobDescBg:addChild(titleLabel)

    descListView = ccui.ListView:create()
    descListView:setDirection(ccui.ScrollViewDir.vertical)
    -- descListView:setBounceEnabled(true)
    descListView:setContentSize(cc.size(470, 135))
    descListView:setItemsMargin(10)
    descListView:setGravity(ccui.ListViewGravity.centerHorizontal)
    descListView:setAnchorPoint(cc.p(0.5, 0))
    descListView:setPosition(320, 5)
    self.jobDescBg:addChild(descListView)
    local descHight = 0
    for i, descText in ipairs(jobConfig.jobDesc) do
        local descLabel = ui.newLabel({
                text = descText,
                color = cc.c3b(0x46, 0x22, 0x0d),
                dimensions = cc.size(450, 0)
            })
        descLabel:setAnchorPoint(cc.p(0.5, 1))
        descListView:pushBackCustomItem(descLabel)

        descHight = descHight + descLabel:getContentSize().height + 10
    end
end

function JianghuKillSeleJobLayer:getJobConfig(jobId)
    local jobConfigList = {
        [1] = {     -- 豪杰
            jobId = 1,
            jobTexture = "jhs_54.png",
            jobDesc = {
                TR("1.有豪杰驻守时，其他驻守职业玩家不能被攻击（刺客除外，可以攻击）"),
                TR("2.精神恢复速度提升"),
                TR("3.其他职业（书生除外）攻击豪杰时，需要额外消耗1点功力"),
            },
        },
        [2] = {     -- 刺客
            jobId = 2,
            jobTexture = "jhs_53.png",
            jobDesc = {
                TR("1.进攻时，使用“突袭”代替普通进攻，突袭：指定攻击某个驻守玩家，并且有伤害加成，有一定几率触发"),
                TR("2.功力恢复速度加成"),
            },
        },
        [3] = {     -- 书生
            jobId = 3,
            jobTexture = "jhs_55.png",
            jobDesc = {
                TR("1.有书生驻守门派时，门派产出天机残页速度提升20%，最多可叠加5层效果，即最多提升100%"),
                TR("2.领悟时，有概率触发“心有灵犀”技能，可以额外获得1张天机残页（额外获得的不会从门派储存里扣除）"),
                TR("3.书生攻击豪杰时只消耗1点功力"),
            },
        },
        [4] = {     -- 镖师
            jobId = 4,
            jobTexture = "jhs_56.png",
            jobDesc = {
                TR("1.草料恢复速度提升"),
                TR("2.可以驾驶马车出行，出行速度提升100%，镖师草料减少50%消耗"),
                TR("3.镖师作为队长时，其他队员不消耗草料"),
            },
        },
    }

    return jobConfigList[jobId]
end

--===================================网络相关===================================
-- 获取职业数据
function JianghuKillSeleJobLayer:requestInfo()
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "GetJobRatioInfo",
        svrMethodData = {},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end

            -- 职业选择比例
            self.mJobRatio = response.Value.JianghuKillJobRatio

            self:initUI()
        end
    })
end
-- 选择职业
function JianghuKillSeleJobLayer:requestSelectJob()
    HttpClient:request({
        moduleName = "Jianghukill",
        methodName = "ChooseJob",
        svrMethodData = {self.mJobId},
        callbackNode = self,
        callback = function(response)
            -- 容错处理
            if response.Status ~= 0 then
                return
            end

            if self.mCallback then
                self.mCallback(response)
            end

            LayerManager.removeLayer(self)
        end
    })
end

return JianghuKillSeleJobLayer