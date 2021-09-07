 ----------------------------------------------------------
-- 逻辑模块 - 宠物
-- ----------------------------------------------------------
PetManager = PetManager or BaseClass(BaseManager)

-- PetManager.event_update_pet = "Update_Pet"
--宠物的某项属性改变
-- 特殊 showGenreEffect 变异特效
-- PetManager.event_pet_update = "Pet_Update"
-- PetManager.event_change_battlepet = "Change_BattlePet"

-- PetManager.event_update_petshop = "Update_PetShop"
PetManager.event_pet_modelpreview_idle = "event_pet_modelpreview_idle"

PetManager.event_pet_quick_show = "event_pet_quick_show"

function PetManager:__init()
    if PetManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
    end

	PetManager.Instance = self

    self.model = PetModel.New()

    -- 护符熔炼次数
    self.moonTimes = 0
    self.sunTimes = 0

    self:InitHandler()

    self.OnUpdatePetList = EventLib.New()
    self.OnSelectPet = EventLib.New()
    self.OnPetUpdate = EventLib.New() -- info skills stones grade upgrade attrs quality
    self.OnPetShopUpdate = EventLib.New()
    self.OnPetArtificeUpdate = EventLib.New()
    self.OnPetTmpAttrUpdate = EventLib.New()
    self.OnPetSaveFnish = EventLib.New()
    self.onReceiveValue = EventLib.New()
    -- EventMgr.Instance:AddListener(event_name.socket_connect, function() self:onConnected() end)
    self.isWash = false
    self.curGemPrice = 0
    self.market_price = {}
    self.onGetPrice = EventLib.New()

    self.On10526ButtonFreezon = EventLib.New()

    self.OnPetWashFreeCount = EventLib.New()

    self.OnPetRuneStudyUpgrade = EventLib.New() --宠物内丹镶嵌/升级

    self.OnPetRuneResonances = EventLib.New() --宠物内丹共鸣/重置
end

function PetManager:__delete()

    self.On10526ButtonFreezon:DeleteMe()
    self.On10526ButtonFreezon = nil

    self.OnUpdatePetList:DeleteMe()
    self.OnUpdatePetList = nil

    self.onReceiveValue:DeleteMe()
    self.onReceiveValue = nil

    self.OnSelectPet:DeleteMe()   --genju id xuanzechongwu
    self.OnSelectPet = nil

    self.OnPetUpdate:DeleteMe()
    self.OnPetUpdate = nil
    self.OnPetShopUpdate:DeleteMe()
    self.OnPetShopUpdate = nil
    self.OnPetArtificeUpdate:DeleteMe()
    self.OnPetArtificeUpdate = nil
    self.OnPetTmpAttrUpdate:DeleteMe()
    self.OnPetTmpAttrUpdate = nil

    self.OnPetWashFreeCount:DeleteMe()
    self.OnPetWashFreeCount = nil

    self.OnPetRuneStudyUpgrad:DeleteMe()
    self.OnPetRuneStudyUpgrade = nil

    self.OnPetRuneResonances:DeleteMe()
    self.OnPetRuneResonances = nil
end

function PetManager:InitHandler()
    -- 最好是把所有的回调函数在连接之前全部添加
    -- 除非你很确定那些协议不会在连接后立即发送过来
    self:AddNetHandler(10500, self.On10500)
    self:AddNetHandler(10501, self.On10501)
    self:AddNetHandler(10502, self.On10502)
    self:AddNetHandler(10503, self.On10503)
    self:AddNetHandler(10504, self.On10504)
    self:AddNetHandler(10505, self.On10505)

    self:AddNetHandler(10507, self.On10507)
    self:AddNetHandler(10508, self.On10508)
    self:AddNetHandler(10509, self.On10509)
    self:AddNetHandler(10510, self.On10510)
    self:AddNetHandler(10511, self.On10511)
    self:AddNetHandler(10512, self.On10512)
    self:AddNetHandler(10513, self.On10513)
    self:AddNetHandler(10514, self.On10514)
    self:AddNetHandler(10515, self.On10515)
    self:AddNetHandler(10516, self.On10516)
    self:AddNetHandler(10517, self.On10517)
    self:AddNetHandler(10518, self.On10518)
    self:AddNetHandler(10519, self.On10519)
    self:AddNetHandler(10520, self.On10520)
    self:AddNetHandler(10521, self.On10521)
    self:AddNetHandler(10522, self.On10522)
    self:AddNetHandler(10523, self.On10523)
    self:AddNetHandler(10524, self.On10524)
    self:AddNetHandler(10525, self.On10525)
    self:AddNetHandler(10526, self.On10526)
    self:AddNetHandler(10527, self.On10527)
    self:AddNetHandler(10528, self.On10528)
    self:AddNetHandler(10529, self.On10529)
    self:AddNetHandler(10530, self.On10530)
    self:AddNetHandler(10531, self.On10531)
    self:AddNetHandler(10532, self.On10532)
    self:AddNetHandler(10533, self.On10533)
    self:AddNetHandler(10534, self.On10534)
    self:AddNetHandler(10535, self.On10535)
    self:AddNetHandler(10536, self.On10536)
    self:AddNetHandler(10537, self.On10537)
    self:AddNetHandler(10538, self.On10538)
    self:AddNetHandler(10540, self.On10540)
    self:AddNetHandler(10541, self.On10541)
    self:AddNetHandler(10542, self.On10542)
    self:AddNetHandler(10543, self.On10543)
    self:AddNetHandler(10544, self.On10544)
    self:AddNetHandler(10546, self.On10546)
    self:AddNetHandler(10547, self.On10547)
    self:AddNetHandler(10548, self.On10548)
    self:AddNetHandler(10549, self.On10549)
    self:AddNetHandler(10550, self.On10550)
    self:AddNetHandler(10551, self.On10551)
    self:AddNetHandler(10552, self.On10552)
    self:AddNetHandler(10553, self.On10553)
    self:AddNetHandler(10554, self.On10554)
    self:AddNetHandler(10555, self.On10555)
    self:AddNetHandler(10556, self.On10556)
    self:AddNetHandler(10557, self.On10557)
    self:AddNetHandler(10558, self.On10558)
    self:AddNetHandler(10559, self.On10559)
    self:AddNetHandler(10560, self.On10560)
    self:AddNetHandler(10561, self.On10561)
    self:AddNetHandler(10562, self.On10562)
    self:AddNetHandler(10563, self.On10563)
    self:AddNetHandler(10564, self.On10564)
    self:AddNetHandler(10565, self.On10565)
    self:AddNetHandler(10566, self.On10566)
    self:AddNetHandler(10567, self.On10567)
    self:AddNetHandler(10568, self.On10568)
    self:AddNetHandler(10569, self.On10569)  --领取精灵蛋
    self:AddNetHandler(10570, self.On10570)  --孵化精灵蛋
    self:AddNetHandler(10571, self.On10571)  --进化精灵蛋
    self:AddNetHandler(10572, self.On10572)  --月卡特权洗髓次数
    self:AddNetHandler(10573, self.On10573)
    self:AddNetHandler(10574, self.On10574)

    self:AddNetHandler(10575, self.On10575) --镶嵌/升级内丹(符文)
    self:AddNetHandler(10576, self.On10576) --内丹(符文)领悟
    self:AddNetHandler(10577, self.On10577) --内丹(符文)遗忘
    self:AddNetHandler(10578, self.On10578) --内丹(符文)共鸣激活/重置
    self:AddNetHandler(10579, self.On10579) --内丹(符文)更新


    self:AddNetHandler(10337, self.On10337)
    self:AddNetHandler(10408, self.On10408)
    self:AddNetHandler(18633, self.On18633)
    self:AddNetHandler(18634, self.On18634)
    self:AddNetHandler(12416, self.On12416)
end

-------------------------------------------
-------------------------------------------
------------- 协议处理 -----------------
-------------------------------------------
-------------------------------------------

function PetManager:Send10500()
    -- print("发送协议10500==============================================================================================================================================================")
    Connection.Instance:send(10500, { })
end

function PetManager:On10500(data)
    -- BaseUtils.dump(data,"<color='#ff0000'>PetManager:On10500(data) === =========================================================================================</color>")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10500(data)
end

function PetManager:Send10501(id, mode)
    Connection.Instance:send(10501, { id = id, mode = mode })
end

function PetManager:On10501(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function PetManager:On10502(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10502(data)
end

function PetManager:On10503(data)
    -- BaseUtils.dump(data, "Oend10503")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10503(data)
end

function PetManager:On10504(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10504(data)
end

function PetManager:Send10505(id, item_flag)
    if RoleManager.Instance.RoleData.lev < 50 then
        local petData,_ = PetManager.Instance.model:getpet_byid(id)
        if petData ~= nil and petData.base_id ~= 10003 then
            QuestManager.Instance.model.lastGuidePetWash = nil
        end
    end
    self.isWash = true
    Connection.Instance:send(10505, { id = id, item_flag = item_flag })
end

function PetManager:On10505(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if self.model.window ~= nil and self.model.window.childTab[2] ~= nil and self.model.window.childTab[2].watchbuttonscript ~= nil then
        self.model.window.childTab[2].watchbuttonscript:ReleaseFrozon()
    end
    self.model:On10505(data)
    self:Send10572()
end

function PetManager:On10506(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function PetManager:Send10507(id, item_id, hole_id)
    Connection.Instance:send(10507, { id = id, item_id = item_id, hole_id = hole_id })
end

function PetManager:On10507(data)



end

function PetManager:Send10508(id, item_id)
    Connection.Instance:send(10508, { id = id, item_id = item_id })
end

function PetManager:On10508(data)
    -- print("On10508")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        WindowManager.Instance:CloseWindowById(WindowConfig.WinID.pet_learnskill)
        SoundManager.Instance:Play(260)
    end
end

function PetManager:Send10509(id)
    Connection.Instance:send(10509, { id = id })
    print("PetManager:Send10509(id)")
end

function PetManager:On10509(data)
    BaseUtils.dump(data, "10509")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10509(data)
end

function PetManager:Send10510(id, aptitude)
    Connection.Instance:send(10510, { id = id, aptitude = aptitude })
end

function PetManager:On10510(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if self.model.feedWindow ~= nil and self.model.feedWindow.childTab[2] ~= nil  then
        if self.model.feedWindow.childTab[2].frozenButton ~= nil then self.model.feedWindow.childTab[2].frozenButton:Release() end
        if self.model.feedWindow.childTab[2].buttonscript ~= nil then self.model.feedWindow.childTab[2].buttonscript:ReleaseFrozon() end
    end
    if data.flag == 1 then
        SoundManager.Instance:Play(241)
    end
end


function PetManager:On10511(data)
    BaseUtils.dump(data, "On10511")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10511(data)
end

function PetManager:On10512(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10512(data)
end

function PetManager:Send10513(id, info)
    Connection.Instance:send(10513, { id = id
            , strength = info[2], constitution = info[1]
            , magic = info[3], agility = info[4], endurance = info[5] })
end

function PetManager:On10513(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        SoundManager.Instance:Play(244)
    end
end

function PetManager:Send10514(id, possess_pos)
    Connection.Instance:send(10514, { id = id, possess_pos = possess_pos})
end

function PetManager:On10514(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function PetManager:Send10519(id, name)
    Connection.Instance:send(10519, { id = id, name = name })
end

function PetManager:On10519(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10519(data)
end

function PetManager:Send10520(id, info)
    Connection.Instance:send(10520, { id = id
        , strength = info[2], constitution = info[1]
        , magic = info[3], agility = info[4], endurance = info[5] })
end

function PetManager:On10520(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10520(data)
end

function PetManager:Send10521(id)
    Connection.Instance:send(10521, { id = id })
end

function PetManager:On10521(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10521(data)
end

function PetManager:Send10522(id)
    Connection.Instance:send(10522, { id = id })
end

function PetManager:On10522(data)
    -- QuestManager.Instance:Notice(data.msg)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        for i=1, #self.model.petlist do
            if self.model.petlist[i].id == data.id then
                table.remove(self.model.petlist, i)
                self.OnUpdatePetList:Fire()
                break
            end
        end
    end
end

function PetManager:Send10523()
    Connection.Instance:send(10523, { })
end

function PetManager:On10523(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model.pet_nums = data.pet_nums
        self.OnUpdatePetList:Fire()
    end
end

function PetManager:On10525(data)
    self.model:On10525(data)
end

function PetManager:Send10526(id)
    Connection.Instance:send(10526, { id = id })
end

function PetManager:On10526(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model.On10526ButtonState = true
    else
        self.model.On10526ButtonState = false
    end
    self.On10526ButtonFreezon:Fire()
end

function PetManager:Send10527()
    Connection.Instance:send(10527, { })
end

function PetManager:On10527(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.model.fresh_id = data.fresh_id
        -- self.model.nextGetTime = math.max(0, data.time - BaseUtils.BASE_TIME)
        self.model.nextGetTime = data.time
        self.model:update_receivepet()
    end
end

-- -------------------------------------------
-- 仓库宠物
-- -------------------------------------------
function PetManager:Send10528()
    Connection.Instance:send(10528, { })
end
--仓库宠物数据
function PetManager:On10528(data)
    BackpackManager.Instance.storeModel:On10528(data)
end

function PetManager:Send10529(idTemp)
    Connection.Instance:send(10529, { id = idTemp })
end

function PetManager:On10529(data)
    BackpackManager.Instance.storeModel:On10529(data)
end

function PetManager:Send10530(idTemp)
    Connection.Instance:send(10530, { id = idTemp})
end

function PetManager:On10530(data)
    BackpackManager.Instance.storeModel:On10530(data)
end

function PetManager:Send10531()
    Connection.Instance:send(10531, { })
end

function PetManager:On10531(data)
    BackpackManager.Instance.storeModel:On10531(data)
end

function PetManager:Send10532(idTemp)
    Connection.Instance:send(10532, { id = idTemp })
end

function PetManager:On10532(data)
    BackpackManager.Instance.storeModel:On10532(data)
end

function PetManager:Send10533()
    Connection.Instance:send(10533, { })
end

function PetManager:On10533(data)
    BackpackManager.Instance.storeModel:On10533(data)
end

function PetManager:Send10535(id)
    Connection.Instance:send(10535, {id = id})
end

function PetManager:On10535(data)
    -- BackpackManager.Instance.storeModel:On10535(data)
    -- BaseUtils.dump(data,"On10535")
    self.model:OpenPetSetTalkPanel(data)
end

function PetManager:Send10536(id, type, msg)
    self.changeTalk_type = type
    self.changeTalk_msg = msg
    Connection.Instance:send(10536, {id = id , type = type, msg = msg})
end

function PetManager:On10536(data)
    if data.result == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("保存成功"))
        -- if self.changeTalk_type ~= nil then
        --     self.model.pettalk_data.combat_talk[self.changeTalk_type].msg = self.changeTalk_msg
        -- end
        self.changeTalk_type = nil
        self.changeTalk_msg = nil
    else
        self.changeTalk_type = nil
        self.changeTalk_msg = nil
        NoticeManager.Instance:FloatTipsByString(data.reason)
        self.model:UpdatePetTalkPanel()
    end
    -- BackpackManager.Instance.storeModel:On10536(data)
end

-- -------------------------------------------
-- 嗯，又回到宠物了
-- -------------------------------------------
function PetManager:Send10534(id)
    Connection.Instance:send(10534, { id = id })
end

function PetManager:On10534(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function PetManager:Send10537(id)
    Connection.Instance:send(10537, { id = id })
end

function PetManager:On10537(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.op_code == 1 then
        local petdata = self.model:getpet_byid(data.id)
        petdata.lock = 1
        PetManager.Instance.OnPetUpdate:Fire({"base", "info"})
    end
end

function PetManager:Send10538(id)
    Connection.Instance:send(10538, { id = id })
end

function PetManager:On10538(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.op_code == 1 then
        local petdata = self.model:getpet_byid(data.id)
        petdata.lock = 0
        PetManager.Instance.OnPetUpdate:Fire({"base", "info"})
    end
end

function PetManager:Send10540(id)
    Connection.Instance:send(10540, {id = id})
end

function PetManager:On10540(dat)
    if dat.msg ~= nil and dat.msg ~= "" then
        NoticeManager.Instance:FloatTipsByString(dat.msg)
    end
end
--符石洗炼
function PetManager:Send10541(petId,itemId)
    Connection.Instance:send(10541, {pet_id = petId,item_id = itemId})
end
--符石洗炼
function PetManager:On10541(dat)
    -- BaseUtils.dump(dat,"PetManager:On10541(dat)==")
    if dat.result == 1 then
        EventMgr.Instance:Fire(event_name.pet_stone_wash_succ)
    end
end
--符石保存洗炼
function PetManager:Send10542(petId,itemId)
    Connection.Instance:send(10542, {pet_id = petId,item_id = itemId})
end
--符石保存洗炼
function PetManager:On10542(dat)
    -- BaseUtils.dump(dat,"PetManager:On10542(dat)==")
    if dat.result == 1 then
        EventMgr.Instance:Fire(event_name.pet_stone_wash_save_succ)
    end
end
--宠物每天洗髓次数
function PetManager:Send10543()
    Connection.Instance:send(10543)
end
--宠物每天洗髓次数
function PetManager:On10543(data)
    self.model.today_wash_num = data.num
    if self.model.today_wash_num >= 10 then
        PetManager.Instance.OnPetUpdate:Fire({"washitem"})
    end
end

--符石刻印
function PetManager:Send10544(pet_id, stone_id, item_id)
    print("1----------------------------发送10544")
    Connection.Instance:send(10544, {pet_id = pet_id, stone_id = stone_id, item_id = item_id})
end

--符石刻印
function PetManager:On10544(data)
    print("1----------------------------收到10544")
    if data.flag == 0 then --失败

    else--成功
        self.model:OnPlayStoneMarkEffect()
    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--宠物快捷学习技能书
function PetManager:Send10546(id, base_id)
    print(base_id)
    Connection.Instance:send(10546, { id = id, base_id = base_id })
end

--宠物快捷学习技能书
function PetManager:On10546(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        SoundManager.Instance:Play(261)
    end
end

--获得宠物大框提示
function PetManager:On10547(data)
    local action = DramaAction.New()
    action.val = data.pet_base_id
    action.genre = data.genre
    local a = DramaGetPet.New()
    a.callback = function ()
        -- body
        a:DeleteMe()
        a = nil
    end
    a:Show(action)
end

--宠物洗炼
function PetManager:Send10548(id, id_sub)
    -- print("Send10548")
    Connection.Instance:send(10548, { id = id, id_sub = id_sub })
end

--宠物洗炼
function PetManager:On10548(data)
    -- print("Oend10548")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.OnPetArtificeUpdate:Fire()
    end
end

-- 宠物护符洗炼
function PetManager:Send10549(id)
    Connection.Instance:send(10549, {id = id})
end

function PetManager:On10549(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.result == 1 then
        self.moonTimes = data.moon
        self.sunTimes = data.sun
    end
end

-- 宠物突破
function PetManager:Send10550(id)
    Connection.Instance:send(10550, {id = id})
    -- print("Send10550")
    -- print(id)
end

function PetManager:On10550(data)
    -- BaseUtils.dump(data, "On10550")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10550(data)
end

-- 获取护符已熔炼次数
function PetManager:Send10551()
    self:Send(10551, {})
end

function PetManager:On10551(dat)
    self.moonTimes = dat.moon
    self.sunTimes = dat.sun
end

function PetManager:Send10552()
    Connection.Instance:send(10552, {})
end

function PetManager:On10552(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- BaseUtils.dump(data, "On1014")
    -- if data.flag == 1 then
    --     -- self.sceneElementsModel:Self_Transport(10009, 0, 0)
    -- else
    --     local currentNpcData = BaseUtils.copytab(DataUnit.data_unit[20090])
    --     currentNpcData.baseid = 20090
    --     local extra = {}
    --     extra.base = BaseUtils.copytab(DataUnit.data_unit[20090])
    --     extra.base.buttons = {
    --         {button_id = DialogEumn.ActionType.action86, button_args = { 1 }, button_desc = TI18N("<color='#ffff00'>查看剧情任务</color>"), button_show = ""}
    --         , {button_id = 999, button_args = {}, button_desc = TI18N("聊点别的"), button_show = ""}
    --     }
    --     extra.base.plot_talk = TI18N("完成<color='#ffff00'>100级剧情任务-[神侍考验]</color>后才能获得通往<color='#ffff00'>失落神殿</color>的资格，据我所知你还没完成呢，好好加油吧{face_1,3}")
    --     MainUIManager.Instance.dialogModel:Open(currentNpcData, extra, true)
    -- end
end

function PetManager:Send10553(id, skill_id)
    Connection.Instance:send(10553, { id = id, skill_id = skill_id })
end

function PetManager:On10553(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--启用临时洗髓
function PetManager:Send10554(id)
    Connection.Instance:send(10554, { id = id})
end

--启用临时洗髓返回
function PetManager:On10554(data)
    -- print("========================收到===10554")
    -- BaseUtils.dump(data)
    if data.flag == 1 then
        self.OnPetSaveFnish:Fire()
    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end


--请求临时洗髓属性
function PetManager:Send10555(id)
    Connection.Instance:send(10555, {id = id})
end

--请求临时洗髓属性返回
function PetManager:On10555(data)
    -- print("----------------------收到10555")
    -- BaseUtils.dump(data)
    self.OnPetTmpAttrUpdate:Fire(data)
end

--使用宠物经验书
function PetManager:Send10556(id, num)
    print("----------------------发送10556")
    Connection.Instance:send(10556, {id = id, num = num})
end

--使用宠物经验书返回
function PetManager:On10556(data)
    print("----------------------收到10556")
    -- BaseUtils.dump(data)
    if data.flag == 1 then

    else

    end
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--宠物染色
function PetManager:Send10557(id, skin_id)
    Connection.Instance:send(10557, {id = id, skin_id = skin_id})
end

--宠物染色
function PetManager:On10557(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 and self.model.petSkinhWindow ~= nil then
        self.model.petSkinhWindow:OpenGetPetWindow()
    end
end

--宠物使用染色
function PetManager:Send10558(id, skin_id)
    Connection.Instance:send(10558, {id = id, skin_id = skin_id})
end

--宠物使用染色
function PetManager:On10558(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--宠物染色更新
function PetManager:Send10559()
    Connection.Instance:send(10559, {})
end

--宠物染色更新
function PetManager:On10559(data)
    local petData = self.model:getpet_byid(data.id)
    petData.use_skin = data.use_skin
    petData.has_skin = data.has_skin
    self.model:update_battlepet()
    PetManager.Instance.OnPetUpdate:Fire({"use_skin"})
end

--宠物合成
function PetManager:Send10560(base_id)
    Connection.Instance:send(10560, { base_id = base_id })
end

--宠物合成
function PetManager:On10560(data)
    -- BaseUtils.dump(data, "On10560")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        self.model:ClosePetFuseWindow()

        -- local action = DramaAction.New()
        -- action.val = data.base_id
        -- local a = DramaGetPet.New()
        -- a.callback = function ()
        --     a:DeleteMe()
        --     a = nil
        -- end
        -- a:Show(action)
    end
end

--宠物附灵
function PetManager:Send10561(master_pet_id, attach_pet_id)
    Connection.Instance:send(10561, { master_pet_id = master_pet_id, attach_pet_id = attach_pet_id })
end

--宠物附灵
function PetManager:On10561(data)
    -- BaseUtils.dump(data, "On10561")
    NoticeManager.Instance:FloatTipsByString(data.msg)

    if data.flag == 1 then
        self.model:OpenPetSpiritSuccessPanel({ mainPetData = self.model.tempSpirtMainPetData, spritPetData = self.model.tempSpirtSubPetData })
    end
end

--取消附灵
function PetManager:Send10562(attach_pet_id)
    Connection.Instance:send(10562, { attach_pet_id = attach_pet_id })
end

--取消附灵
function PetManager:On10562(data)
    -- BaseUtils.dump(data, "On10562")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        PetManager.Instance.OnUpdatePetList:Fire()
        -- LuaTimer.Add(200, function()
        --         PetManager.Instance.OnUpdatePetList:Fire()
        --     end)
    end
end

--查看护符未保存技能
function PetManager:Send10563(id)
    Connection.Instance:send(10563, { id = id })
end

--查看护符未保存技能
function PetManager:On10563(data)
    -- BaseUtils.dump(data, "On10563")
    if self.model.gemwashwindow ~= nil then
        self.model.gemwashwindow:SetTempAttr(data)
    elseif ChildrenManager.Instance.model.childgemwashview ~= nil then
        ChildrenManager.Instance.model.childgemwashview:SetTempAttr(data)
    end
end

--护符保存技能
function PetManager:Send10564(id)
    Connection.Instance:send(10564, { id = id })
end

--护符保存技能
function PetManager:On10564(data)
    -- BaseUtils.dump(data, "On10564")
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
    end
end

function PetManager:Send10565(id, itemid)
    Connection.Instance:send(10565, {pet_id = id, item_id = itemid})
end

function PetManager:On10565(data)
    -- BaseUtils.dump(data,"On10337")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

function PetManager:Send10566(id, id_sub)
    Connection.Instance:send(10566, {id = id, id_sub = id_sub})
end

function PetManager:On10566(data)
    -- BaseUtils.dump(data,"On10566")
    self.model.artificeAttrData = data.attr
    self.OnPetUpdate:Fire({})
end

--领取精灵蛋
function PetManager:Send10569()
    Connection.Instance:send(10569)
end

function PetManager:On10569(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10569(data)
end

--孵化精灵蛋
function PetManager:Send10570()
    Connection.Instance:send(10570)
end

function PetManager:On10570(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10570(data)
end

--进化精灵蛋
function PetManager:Send10571()
    Connection.Instance:send(10571)
end


function PetManager:On10571(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    self.model:On10571(data)
end

--月卡特权宠物洗髓
function PetManager:Send10572()
    Connection.Instance:send(10572)
end


function PetManager:On10572(data)
    if data ~= nil then
        self.OnPetWashFreeCount:Fire(data)
    end
end

function PetManager:Send10573(pet_id, skill_id)
    Connection.Instance:send(10573, { pet_id = pet_id, skill_id = skill_id })
end

function PetManager:On10573(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then
        self.model:ClosePetChangeSkillPanel()
    end
end

function PetManager:Send10574(pet_id, unreal_flag)
    Connection.Instance:send(10574, { pet_id = pet_id, unreal_flag = unreal_flag })
end

function PetManager:On10574(data)

end

--镶嵌/升级内丹(符文)
function PetManager:Send10575(pet_id, rune_index, rune_id)
    Connection.Instance:send(10575, { pet_id = pet_id, rune_index = rune_index, rune_id = rune_id})
end

function PetManager:On10575(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- BaseUtils.dump(data,"On10575")
    if data.flag == 1 then 
        self.model:ClosePetRuneStudyPanel()
        self.OnPetRuneStudyUpgrade:Fire(data)
    end
end

--内丹(符文)领悟
function PetManager:Send10576(pet_id, rune_index, type)
    Connection.Instance:send(10576, { pet_id = pet_id, rune_index = rune_index, type = type})
end

function PetManager:On10576(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then 
        self.model:ClosePetSavvyRunePanel()
    end
end

--内丹(符文)遗忘
function PetManager:Send10577(pet_id, rune_index)
    Connection.Instance:send(10577, {pet_id = pet_id, rune_index = rune_index})
end

function PetManager:On10577(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--内丹(符文)共鸣激活/重置
function PetManager:Send10578(pet_id, resonance_index)
    Connection.Instance:send(10578, {pet_id = pet_id, resonance_index = resonance_index})
end

function PetManager:On10578(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    if data.flag == 1 then 
        self.OnPetRuneResonances:Fire(data.resonance_index)
    end
end

--内丹(符文)更新
function PetManager:Send10579()
    Connection.Instance:send(10579, {})
end

function PetManager:On10579(data)
    self.model:On10579(data)
end




--是否具有深海灵蕴
function PetManager:HasEvolveEgg()
    for i,v in ipairs(self.model.petlist) do
        if v.genre == 6 and v.base_id == 20013 and v.grade == 1 then
            return true
        end
    end
    return false
end






--- 选择超级护符
function PetManager:Send10337(id, flag)
    Connection.Instance:send(10337, {id = id, flag = flag})
end

function PetManager:On10337(data)
    -- BaseUtils.dump(data,"On10337")
    NoticeManager.Instance:FloatTipsByString(data.msg)
end

--- 孩子闲聊数据请求
function PetManager:Send18633(child_id, platform, zone_id)
    Connection.Instance:send(18633, {child_id = child_id, platform = platform, zone_id = zone_id})
end

function PetManager:On18633(data)
    -- BaseUtils.dump(data,"On18633")
    self.model:OpenChildSetTalkPanel(data)
end

function PetManager:Send18634(child_id, platform, zone_id, type, msg)
    self.changeTalk_type = type
    self.changeTalk_msg = msg
    -- BaseUtils.dump({child_id = child_id, platform = platform, zone_id = zone_id, type = type, msg = msg}, "发送的啊啊啊")
    Connection.Instance:send(18634, {child_id = child_id, platform = platform, zone_id = zone_id, type = type, msg = msg})
end

function PetManager:On18634(data)
    if data.result == 1 then
        NoticeManager.Instance:FloatTipsByString(TI18N("保存成功"))
        -- if self.changeTalk_type ~= nil then
        --     self.model.pettalk_data.combat_talk[self.changeTalk_type].msg = self.changeTalk_msg
        -- end
        self.changeTalk_type = nil
        self.changeTalk_msg = nil
    else
        self.changeTalk_type = nil
        self.changeTalk_msg = nil
        NoticeManager.Instance:FloatTipsByString(data.reason)
        self.model:UpdateChildTalkPanel()
    end
    -- BackpackManager.Instance.storeModel:On10536(data)
end
-------------------------------------------
-------------------------------------------
------------- 逻辑处理 -----------------
-------------------------------------------
-------------------------------------------

function PetManager:RequestInitData()
    -- 护符熔炼次数
    self.moonTimes = 0
    self.sunTimes = 0

    self:Send10500()
    self:Send10528()
    self:Send10543()
    self:Send10551()
end


function PetManager:InitData()
    self.model.pet_nums = 5
    self.model.petlist = {}
    self.model.cur_petdata = nil
    self.model.battle_petdata = nil
    -- self.model.quickshow_petdata = nil
    self.model.isnotify_watch = false
    self.model.isnotify_watch_baobao = false
    self.model.select_gem = 1

    self.model.sure_useskillbook = false
    self.model.quickBuySkillBook = false

    self.model.artificeAttrData = {}
end

-- 获取宠物列表
function PetManager:Get_PetList()
    return self.model.petlist
end

-- 获取当前选中的宠物
function PetManager:Get_CurPet()
    return self.model.cur_petdata
end

-- 获取出战宠物
function PetManager:Get_BattlePet()
    return self.model.battle_petdata
end

-- 根据id获取宠物数据
function PetManager:GetPetById(id)
    for i,v in ipairs(self.model.petlist) do
        if id == v.id then
            return BaseUtils.copytab(v)
        end
    end
    return nil
end

function PetManager:Send10567(id)
    print("发送协议10567" .. id)
    Connection.Instance:send(10567, { id = id })
end

function PetManager:On10567(data)
    -- BaseUtils.dump(data,"接收协议10567========================================================================")
    if AddPointManager.Instance.model ~= nil then
       if AddPointManager.Instance.model.addPointView ~= nil then

           AddPointManager.Instance.model.addPointView.slider.petAdditonalPoints[1] = data.extra_attr[1].constitution
           AddPointManager.Instance.model.addPointView.slider.petAdditonalPoints[2] = data.extra_attr[1].strength
           AddPointManager.Instance.model.addPointView.slider.petAdditonalPoints[3] = data.extra_attr[1].magic
           AddPointManager.Instance.model.addPointView.slider.petAdditonalPoints[4] = data.extra_attr[1].agility
           AddPointManager.Instance.model.addPointView.slider.petAdditonalPoints[5] = data.extra_attr[1].endurance

           AddPointManager.Instance.model.addPointView.slider:UpdatePetAddPoints()

       end
    end
end

function PetManager:Send10568(id, base_id, hole_id)
    Connection.Instance:send(10568, { id = id,base_id = base_id, hole_id = hole_id })
    -- print("发送协议10568----------------")
end

function PetManager:On10568(data)
    NoticeManager.Instance:FloatTipsByString(data.msg)
    -- print("收到协议10568----------------")
end

function PetManager:Send12416(base_ids)
    Connection.Instance:send(12416, { base_ids = base_ids })
    -- print("发送协议12416---------------")
end

function PetManager:On12416(data)
    -- print("收到12416--------"..data.market_price[1].price)
    self.curGemPrice = data.market_price[1].price
    self.market_price = data.market_price
    self.onGetPrice:Fire()
end


