--[[
    文件名：RoleCreateLayer.lua
    描述：创建玩家角色页面
    创建人：lichunsheng
    创建时间：2017.5.15
-- ]]

local RoleCreateLayer = class("RoleCreateLayer", function()
    return display.newLayer()
end)

local HeroList = {
    [1] = { -- 男主
        modelId = 12010001,                 -- 模型id
        skillAudio = "hero_nanzhu_pugong.mp3",  -- 普攻音效
        audioDelay = 0.7,                   -- 技能音效延时
        headPic = "jsxz_01.png",            -- 头像图
        textPic = "jsxz_10.png",
        headPos = cc.p(560, 1036),           -- 头像位置
        selectPos = cc.p(555, 1020),
        heroPos = cc.p(320, 380),
        playerSex = 0,                      -- 性别
        isMove = true,                      -- 有位移
    },
    [2] = { -- 男2
        modelId = 12010004,
        skillAudio = "hero_kuangfeng_pugong.mp3",
        audioDelay = 0,
        headPic = "jsxz_02.png",
        textPic = "jsxz_11.png",
        headPos = cc.p(560, 900),
        selectPos = cc.p(555, 895),
        heroPos = cc.p(320, 380),
        playerSex = 1,
    },
    [3] = { -- 男3
        modelId = 12010011,
        skillAudio = "hero_huaishang_pugong.mp3",
        audioDelay = 0.5,
        headPic = "jsxz_03.png",
        textPic = "jsxz_09.png",
        headPos = cc.p(560, 770),
        selectPos = cc.p(555, 765),
        heroPos = cc.p(320, 380),
        playerSex = 2,
    },
    [4] = { -- 女
        modelId = 12010019,
        skillAudio = "hero_liuruyan_pugong.mp3",
        audioDelay = 0.5,
        headPic = "jsxz_12.png",
        textPic = "jsxz_13.png",
        headPos = cc.p(560, 640),
        selectPos = cc.p(555, 635),
        heroPos = cc.p(320, 380),
        playerSex = 3,
    }
}

function RoleCreateLayer:ctor()
    --创建和屏幕大小相同的layer
    self.mParentLayer = ui.newStdLayer()
    self:addChild(self.mParentLayer)
    -- 当前显示皮肤
    self.curHeroId = 1
    -- 列表
    self.HeroList = HeroList

    -- 设随机数种子
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    -- 初始化页面控件
    self:initUI()
end

-- 初始化页面控件
function RoleCreateLayer:initUI()
    -- 创建特效背景
    self:createAniBg()
    -- 创建基础控件
    self:createBaseUI()
    -- 刷新界面
    self:refreshLayer()
end

-- 创建特效背景
function RoleCreateLayer:createAniBg()
    --创建背景
    self.mBgSprite = ui.newSprite("jsxz_08.jpg")
    self.mBgSprite:setPosition(cc.p(320, 568))
    self.mParentLayer:addChild(self.mBgSprite)
    -- 创建背景特效
    local bgEffectOne = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_juesexuanzejiemian",
            animation = "shuibo",
            position = cc.p(370, 260),
            loop = true,
        })
    bgEffectOne:setVisible(false)
    self.shuiboEffect = bgEffectOne
    -- 创建背景特效2
    local bgEffectTwo = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_juesexuanzejiemian",
            animation = "zhuye",
            position = cc.p(320, 568),
            loop = true,
        })
    -- 竹叶飘落
    local flowerEffect = cc.ParticleSystemQuad:create("zuye.plist")
    flowerEffect:setPosVar(cc.p(320, 0))
    flowerEffect:setPosition(display.cx + 100, display.top+200)
    flowerEffect:setTotalParticles(10)
    flowerEffect:setStartSize(30)
    flowerEffect:setStartSizeVar(10)
    flowerEffect:setEndSize(40)
    flowerEffect:setEndSizeVar(10)
    flowerEffect:setGravity(cc.p(-50, -50))
    flowerEffect:resetSystem()
    self.mParentLayer:addChild(flowerEffect, 2)
    -- 创建文字图
    self.textPic = ui.newSprite("jsxz_09.png")
    self.textPic:setPosition(80, 900)
    self.mParentLayer:addChild(self.textPic)
    -- 创建所有角色
    for i, v in ipairs(self.HeroList) do
        local zhujueObj = self:createHero(i)
        zhujueObj:setVisible(false)
    end
end
-- 创建角色
function RoleCreateLayer:createHero(listID)
    -- 获取模型id
    local modelId = self.HeroList[listID].modelId
    if not modelId then return end
    -- 创建人物节点
    local node = cc.Node:create()
    node:setPosition(self.HeroList[listID].heroPos)
    self.mParentLayer:addChild(node)
    -- 创建模型
    local zhujueModel = HeroModel.items[modelId]
    local zhujueAni = ui.newEffect({
        parent = node,
        position = cc.p(0,0),
        scale = 0.3,
        effectName = zhujueModel and zhujueModel.largePic or "hero_nanzhu",
        loop = true,
    })
    -- 创建人物阴影
    local shadowSprite = ui.newSprite("ef_c_67.png")
    shadowSprite:setOpacity(76)
    node:addChild(shadowSprite, -1)
    -- 加入列表
    self.HeroList[listID].effectObj = zhujueAni
    self.HeroList[listID].heroNode = node
    self.HeroList[listID].shadow = shadowSprite
    -- 返回该模型
    return node
end
-- 播放角色pugong
function RoleCreateLayer:playAction(listID)
    -- 获取角色模型
    local zhujueObj = self.HeroList[listID].effectObj
    if not zhujueObj then return end
    -- 切换模型pugong动作
    SkeletonAnimation.action({
            skeleton = zhujueObj,      
            action = "pugong",
            loop = false,     
            completeListener = function()
                -- 播放说话声音
                self:playDaijiAudio(listID)
            end,
            endListener = function()
                zhujueObj:setToSetupPose()
            end,
        })
    -- -- 混合动作
    -- SkeletonAnimation.mix({
    --     skeleton      = zhujueObj,
    --     fromAnimation = "pugong",
    --     toAnimation   = "daiji",
    --     duration      = 1,
    -- })
    -- 切换回待机
    zhujueObj:addAnimation(0, "daiji", true)
    -- 播放pugong音效
    Utility.performWithDelay(self, function()
        -- 停止当前技能音效
        if self.curentSkillSound then
            MqAudio.stopEffect(self.curentSkillSound)
        end
        -- 角色id匹配才播放音效
        if listID == self.curHeroId then
            self.curentSkillSound = MqAudio.playEffect(self.HeroList[listID].skillAudio)
        end
    end,self.HeroList[listID].audioDelay)
    
    -- 移动角色，使其不移到屏幕外
    if self.HeroList[listID].isMove then
        local originPos = self.HeroList[listID].heroPos
        local move1 = cc.MoveTo:create(2, cc.p(originPos.x-420, originPos.y))
        local move2 = cc.MoveTo:create(0.8, cc.p(originPos.x, originPos.y))
        local seq = cc.Sequence:create(move1, move2)
        HeroList[listID].heroNode:runAction(seq)
    end
end
-- 播放说话声音
function RoleCreateLayer:playDaijiAudio(listID)
    if self.curHeroId ~= listID then return end
    -- 模型id
    local modelId = self.HeroList[listID].modelId
    if not modelId then return end
    -- 播放切换音效
    local heroModel = HeroModel.items[modelId]
    -- 停止当前角色音效
    if self.curentSoundID ~= nil then
        MqAudio.stopEffect(self.curentSoundID)
        self.curentSoundID = nil
    end
    -- 角色id匹配才播放音效
    if listID == self.curHeroId then
        local _, staySound = Utility.getHeroSound(heroModel)
        self.curentSoundID = MqAudio.playEffect(Utility.randomStayAudio(staySound))
    end
end
-- 创建传送门特效
function RoleCreateLayer:createChuanSong()
    local chuansongEffect = ui.newEffect({
            parent = self.mParentLayer,
            effectName = "effect_ui_chuansongmen",
            animation = "chuansongmen",
            position = cc.p(320, 850),
            loop = true,
        })
    self.chuansongEffect =  chuansongEffect
    local maskTexture = cc.Director:getInstance():getTextureCache():addImage("zeizhao.png")
    local m_waveSpeedFactor = 0.05
    local m_waveFactor = cc.p(0.003, 0.001)
    local m_enableGray = 0
    local m_enableMask = 1
    local m_time = 0


    local waveShader = self:getImageWaveShader()

    local m_uTime = gl.getUniformLocation(waveShader:getProgram(), "time")
    local m_uEnableMask = gl.getUniformLocation(waveShader:getProgram(), "enable_mask")
    local m_uWaveFactor = gl.getUniformLocation(waveShader:getProgram(), "wave_factor")
    local m_uEnableGray = gl.getUniformLocation(waveShader:getProgram(), "enable_gray")
    local m_uMaskTexture = gl.getUniformLocation(waveShader:getProgram(), "mask_Texture")
    local m_uMaskUvOffset = gl.getUniformLocation(waveShader:getProgram(), "maskUvOffset")


    local programState = cc.GLProgramState:create(waveShader)
    programState:setUniformFloat(m_uTime, (m_time * m_waveSpeedFactor))
    programState:setUniformVec2(m_uWaveFactor, m_waveFactor)
    programState:setUniformInt(m_uEnableGray, m_enableGray)
    programState:setUniformInt(m_uEnableMask, m_enableMask)
    programState:setUniformTexture("mask_Texture", maskTexture:getName())
    programState:setUniformVec2(m_uMaskUvOffset, cc.p(-0.05, -0.03))


    local m_dt = 1
    local function localUpdate(dt)
        m_time = m_time + dt * m_dt

        if m_time >= 1.0 then
            m_dt = -1
        elseif m_time <= 0 then
            m_dt = 1
        end
        
        m_time = cc.clampf(m_time, 0.0, 1.0);

        programState:setUniformFloat(m_uTime, (m_time * m_waveSpeedFactor))
    end

    self:scheduleUpdateWithPriorityLua(localUpdate, 0.3)

    local layerTem = display.newLayer()
    self.mParentLayer:addChild(layerTem)
    layerTem:setGLProgramState(programState)
end
function RoleCreateLayer:getImageWaveShader()
    local cache = cc.GLProgramCache:getInstance()
    local name = "MQ_ShaderImageWave"
    local shader = cache:getGLProgram(name)

    if not shader then
        shader = cc.GLProgram:createWithByteArrays(
            -- vertex shader
            [[
                attribute vec4 a_position;
                attribute vec2 a_texCoord;

                #ifdef GL_ES
                varying mediump vec2 v_texCoord;
                #else
                varying vec2 v_texCoord;
                #endif

                void main()
                {
                    gl_Position = CC_MVPMatrix * a_position;
                    v_texCoord = a_texCoord;
                }
            ]],
            -- fragment shader
            [[
                uniform float time;
                uniform int enable_mask;
                uniform int enable_gray;
                uniform vec2 wave_factor;
                uniform vec2 maskUvOffset;
                uniform sampler2D mask_Texture;

                varying vec2 v_texCoord;

                void main()
                {
                    float gridx = 10.0;
                    float gridy = 10.0;
                    float xslide = gl_FragCoord.x / gridx;
                    float yslide = gl_FragCoord.y / gridy;

                    vec2 uv = v_texCoord.xy;
                    vec2 maskuv = v_texCoord.xy + maskUvOffset;

                    float mask = 1.0;
                    if(enable_mask == 1)
                        mask = texture2D(mask_Texture, maskuv).a;

                    vec2 tex_uv = uv + vec2(cos(xslide * time) * mask * wave_factor.x, cos(yslide * time) * mask * wave_factor.y);

                    vec4 oriColor = texture2D(CC_Texture0, tex_uv);

                    if(enable_gray == 1)
                    {
                        float gray = dot(oriColor.rgb, vec3(0.2, 0.5, 0.2));
                        gl_FragColor = vec4(gray, gray, gray, oriColor.a);
                    }else{
                        gl_FragColor = oriColor;
                    }
                }
            ]]
        )
        cache:addGLProgram(shader, name)
    end

    return shader
end
-- 播放角色跳入
function RoleCreateLayer:playHeroJump(listID)
    -- 隐藏阴影
    self.HeroList[listID].shadow:setVisible(false)
    -- 获取角色模型
    local heroObj = self.HeroList[listID].heroNode
    if not heroObj then return end
    -- 初始化属性
    heroObj:setScale(0)

    -- 动作时间
    local time = 0.5
    -- 创建动作
    local jump = cc.JumpTo:create(time, self.HeroList[listID].heroPos, 500, 1)
    local scale = cc.ScaleTo:create(time, 1)
    local spawn = cc.Spawn:create(jump, scale)
    -- 播放动作
    heroObj:runAction(spawn)

    Utility.performWithDelay(self, function (node)
        -- 显示水波特效
        self.shuiboEffect:setVisible(true)
        -- 显示阴影
        self.HeroList[listID].shadow:setVisible(true)
        -- 可以点击切换按钮
        self.notCanClick = false
    end,time)
    -- 返回播放时间
    return time
end
-- 显示当前角色，隐藏其它角色
function RoleCreateLayer:displayHero(listID)
    for i, v in ipairs(self.HeroList) do
        local heroObj = v.heroNode
        local heroEffect = v.effectObj
        if heroObj then
            -- 重置角色
            if i == listID then
                heroObj:setVisible(true)
                heroObj:stopAllActions()
                heroObj:setPosition(self.HeroList[listID].heroPos)
                heroEffect:setAnimation(0, "daiji", true)
            else
                heroObj:setVisible(false)
            end
        end
    end
end
-- 刷新角色显示
function RoleCreateLayer:refreshHero(listID)
    -- 显示当前角色
    self:displayHero(listID)
    -- 播放角色跳入
    local time = self:playHeroJump(listID)
    -- 播放角色技能
    Utility.performWithDelay(self, function ()
        if listID == self.curHeroId then
            self:playAction(listID)
        end
    end, time)
end
-- 刷新角色头像
function RoleCreateLayer:refreshHeroHead(listID)
    self.mSelectSprite:setPosition(self.HeroList[listID].selectPos)
end

-- -- 创建触摸选择玩家性别的触摸层
-- function RoleCreateLayer:createTouch()
--     local tempNode = cc.Node:create()
--     self.mParentLayer:addChild(tempNode)

--     local beginPos
--     ui.registerSwallowTouch({
--         node = tempNode,
--         allowTouch = false,
--         beganEvent = function(touch, event)
--             beginPos = touch:getLocation()
--             return true
--         end,
--         endedEvent = function(touch, event)
--             local endPos = touch:getLocation()
--             local distX = (endPos.x - beginPos.x) / Adapter.AutoScaleX
--             if self.mPlayerSex == 0 and distX < -20 then
--                 self.mPlayerSex = 1
--                 self:refreshLayer()
--             elseif self.mPlayerSex == 1 and distX > 20 then
--                 self.mPlayerSex = 0
--                 self:refreshLayer()
--             end
--         end
--     })
-- end

-- 创建基础控件
function RoleCreateLayer:createBaseUI( ... )
    -- 性别头像选中框
    self.mSelectSprite = ui.newSprite("jsxz_04.png")
    self.mParentLayer:addChild(self.mSelectSprite)

    -- 创建头像
     for i, v in ipairs(self.HeroList) do
        local heroBtn = ui.newButton({
            normalImage = v.headPic,
            clickAction = function ()
                -- 点击当前头像
                if i == self.curHeroId then
                    return
                -- 不能切换头像
                elseif self.notCanClick then
                    return
                end
                -- 设置 不能切换头像 为true
                self.notCanClick = true
                -- 停止播放说话声
                if self.curentSoundID then
                    MqAudio.stopEffect(self.curentSoundID)
                    self.curentSoundID = nil
                end
                -- 停止播放技能音效
                if self.curentSkillSound then
                    MqAudio.stopEffect(self.curentSkillSound)
                    self.curentSkillSound = nil
                end
                -- 更新当前角色id
                self.curHeroId = i
                -- 隐藏水波特效
                self.shuiboEffect:setVisible(false)

                -- 刷新界面
                self:refreshLayer()
            end,
        })
        heroBtn:setPosition(v.headPos)
        self.mParentLayer:addChild(heroBtn)
        v.heroBtn = heroBtn
     end


    -- 玩家名字输入框
    local nameEdtBox = ui.newEditBox({
        image = "dl_02.png",
        size = cc.size(313, 60),
        fontSize = 40,
        fontColor = Enums.Color.eWhite,
        placeHolder = TR("请问大侠姓名")
    })
    nameEdtBox:setPlaceHolder(TR("请问大侠姓名"))
    nameEdtBox:setAnchorPoint(cc.p(0, 0.5))
    nameEdtBox:setText(self:getRandomName() or "")
    nameEdtBox:setPosition(154.5, 250)
    self.mParentLayer:addChild(nameEdtBox)

    -- 随机玩家名字的按钮
    local randomNameBtn = ui.newButton({
        normalImage="jsxz_06.png",
        position = cc.p(515, 250),
        clickAction = function ()
            local newName = self:getRandomName()
            nameEdtBox:setText(newName or "")
        end,
    })
    self.mParentLayer:addChild(randomNameBtn)

    -- 创建确定按钮
    local ensureBtn = ui.newButton({
        normalImage = "jsxz_07.png",
        clickAction = function ()
            local newName = nameEdtBox:getText()
            if self:asciilen(newName) > 12 then
                ui.showFlashView(TR("输入长度不得超过6个汉字或12个字符"))
                return
            end

            self:requestNewPlayer(newName)
        end,
    })
    ensureBtn:setPosition(320, 110)
    self.mParentLayer:addChild(ensureBtn)
end

-- 不同编码下获取字符串长度
function RoleCreateLayer:asciilen(str)
    local barrier  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    local size = #barrier
    local count, delta = 0, 0
    local c, i, j = 0, #str, 0

    while i > 0 do
        delta, j, c = 1, size, string.byte(str, -i)
        while barrier[j] do
            if c >= barrier[j] then i = i - j; break end
            j = j - 1
        end
        delta = j == 1 and 1 or 2
        count = count + delta
    end
    return count
end

--获得随机名字
function RoleCreateLayer:getRandomName()
    -- quick已经初始化随机生成器了，此时不用再设置
    local firstname, lastname = _firstname, _lastname
    if not firstname then
        local fullpath1 = cc.FileUtils:getInstance():fullPathForFilename(Enums.RandomName.name1)
        local fullpath2 = cc.FileUtils:getInstance():fullPathForFilename(Enums.RandomName.name2)

        local randomString1 = cc.FileUtils:getInstance():getStringFromFile(fullpath1)
        local randomString2 = cc.FileUtils:getInstance():getStringFromFile(fullpath2)

        if #randomString1 == 0 or #randomString2 == 0 then
            return nil
        end

        firstname, lastname = {}, {}
        for i in randomString1:gmatch "%S+" do
            table.insert(firstname, i)
        end

        for i in randomString2:gmatch "%S+" do
            table.insert(lastname, i)
        end

        _firstname, _lastname = firstname, lastname
    end

    local x, y = math.random(1, #firstname), math.random(1, #lastname)
    return firstname[x]..lastname[y]
end

-- 刷新界面
function RoleCreateLayer:refreshLayer()
    -- 刷新角色
    self:refreshHero(self.curHeroId)
    -- 刷新文字图
    self.textPic:setTexture(self.HeroList[self.curHeroId].textPic)
    -- 刷新头像选中框的位置
   self:refreshHeroHead(self.curHeroId)
end

--- ==================== 服务器数据请求相关 =======================
-- 创建玩家新角色
function RoleCreateLayer:requestNewPlayer(newName)
    local playerSex = self.HeroList[self.curHeroId].playerSex
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Player",
        methodName = "NewPlayer",
        guideInfo  = Guide.manager:makeExtentionData(Guide.config.recordID, 10), -- 打点步骤
        svrMethodData = {newName, playerSex},
        callbackNode = self,
        callback = function(response)
            -- 登录游戏服务器失败
            if not response or response.Status ~= 0 then
                return
            end

            self:requestInitData()
        end,
    })
end

-- 获取玩家初始化数据的数据请求
function RoleCreateLayer:requestInitData()
    HttpClient:request({
        svrType = HttpSvrType.eGame,
        moduleName = "Player",
        methodName = "GetInitData",
        svrMethodData = {},
        callback = function(response)
            if not response or response.Status ~= 0 then -- 获取玩家初始化数据第一部分失败
                return
            end

            Player:updateInitData(response.Value)
            -- 给平台设置进入游戏的统计信息
            Utility.cpInvoke("CreateRole")

            Guide.manager:enterGame()
        end,
        callbackNode = self,
    })
end

return RoleCreateLayer
