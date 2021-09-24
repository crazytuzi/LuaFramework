local function api_amixer_item(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    self._cronApi = {
        ["action_produce"] = true,
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },

            ["action_allot"] = {
                item = {"required","string"},
                idx = {"required","number"},
                member = {"required","number"},
            },

            ["action_buy"] = {
                item = {"required","string"},
                idx = {"required","number"},
                cnt = {"required","number"},
            },
        }
    end

    function self.before(request) 
        if not switchIsEnabled('btMix') then
            self.response.ret = -180
            return self.response
        end

        if (not self._cronApi[self._method]) and ( os.time() < (getWeeTs() + 300) ) then
            self.response.ret = -8469
            return self.response
        end
    end

    -- 分配
    function self.action_allot(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        -- local cnt = request.params.cnt  -- 客户端传背包格子数
        local itemId = request.params.item
        local idx = request.params.idx
        local member = request.params.member

        local ainfo,code = M_alliance.getalliance{getuser=1,method=1,aid=mUserinfo.alliance,uid=uid}
        if not ainfo then
            response.ret = code
            return response
        end

        -- 军团和副团才能分配
        if tonumber(ainfo.data.role) < 1 then
            response.ret = -102
            response.role = ainfo.data.role
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance)
        local item = mAmixer.getItemByIdx(idx)
        local mixerCfg = getConfig("bestMixer")

        -- -8462 不在分配期内,不能分配
        if (mAmixer.getItemPtime(item) + mixerCfg.main.privilegeTime) < os.time() then
            response.ret = -8462
            return response
        end

        -- 珍品数据不匹配,请刷新数据后重试
        if mAmixer.getItemId(item) ~= itemId then
            response.ret = -8461
            return response
        end

        -- 该珍品已被分配,不能重新分配
        if mAmixer.getItemOwner(item) then
            response.ret = -8460
            return response
        end

        mAmixer.setItemOwner(item,member)

        if mAmixer.save() then
            response.data.bestMixer ={
                amixer = {
                    items = mAmixer.getItems()
                }
            }

            mAmixer.setItemLog({
                type=1,
                content=string.format("%s-%s-%s",mUserinfo.nickname, getUserObjs(member,true).getModel('userinfo').nickname,itemId)
            })

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 购买珍品
    function self.action_buy(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local itemId = request.params.item
        local idx = request.params.idx
        local cnt = request.params.cnt  -- 客户端传珍品总数

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance)
        local items = mAmixer.getItems()

        -- 珍品数据不匹配,请刷新数据后重试
        -- 后端的珍品总数与客户端不一致了,表示已经有人买过了
        if cnt ~= #items then
            response.ret = -8468
            response.cnt = {cnt, #items}
            response.data.bestMixer ={
                amixer = {
                    items = items,
                }
            }
            return response
        end

        local item = mAmixer.getItemByIdx(idx)
        local mixerCfg = getConfig("bestMixer")

        -- if uobjs.getModel('achievement').level < mixerCfg.main.achieveLevel then
        --     response.ret = -8467
        --     return response
        -- end

        -- 珍品数据不匹配,请刷新数据后重试
        if mAmixer.getItemId(item) ~= itemId then
            response.ret = -8468
            response.item = {mAmixer.getItemId(item),itemId}
            response.data.bestMixer ={
                amixer = {
                    items = items,
                }
            }
            return response
        end

        local ts = os.time()
        -- 特权截止时间
        local privilegeTime = mAmixer.getItemPtime(item) + mixerCfg.main.privilegeTime
        -- 过期时间
        local expireTime = privilegeTime + mixerCfg.main.buyTime

        -- 不在购买期内,不能购买
        if ts > expireTime then
            response.ret = -8463
            return response
        end

        -- 特殊权期内,只能够买分配给自己的道具
        if ts < privilegeTime and mAmixer.getItemOwner(item) ~= uid then
            response.ret = -8463
            return response
        end

        local itemCfg = mixerCfg.itemList[mAmixer.getItemId(item)]
        if not itemCfg then 
            response.errcfg = mAmixer.getItemId(item)
            return response 
        end

        local gemsCost = itemCfg.gemCost
        if gemsCost <= 0 then
            return response
        end

        -- 金币不足
        if not uobjs.getModel('userinfo').useGem(gemsCost) then
            response.ret = -109 
            return response
        end

        if itemCfg.wealth > 0 then
            local execRet,code = M_alliance.addacpoint{
                uid=uid,
                aid=mUserinfo.alliance,
                point=itemCfg.wealth,
                use_rais=itemCfg.contriCost,
            }
       
            if not execRet then
                response.ret = code
                return response
            end
        end

        mAmixer.delItem(idx)
        uobjs.getModel('bag').add(itemCfg.get,1)

        -- 极品融合器-购买珍品
        regActionLogs(uid,1,{action=263,item=itemId,value=gemsCost,params={rais=itemCfg.contriCost}})

        regKfkLogs(mUserinfo.alliance,'amixer',{
                notUser=true,
                addition={
                    {desc="出售珍品",value=itemId},
                    {desc="购买者",value=uid},
                }
            }
        )

        if mAmixer.save() then
            if not uobjs.save() then
                response.err = "user save failed"
                return response
            end

            response.data.bestMixer ={
                amixer = {
                    items = items,
                }
            }

            mAmixer.setItemLog({
                type=2,
                content=mUserinfo.nickname .. "-" .. itemId
            })

            response.ret = 0
            response.msg = 'Success'
        end

        return response
    end

    -- 请求珍品
    function self.action_request(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local itemId = request.params.item
        local text = request.params.text
        local mixerCfg = getConfig("bestMixer")
        if not mixerCfg.itemList[itemId] then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer")
        local itemInfo = tostring(itemId) .. '-' .. tostring(text)
        mAmixer.itemRequest(itemInfo,mUserinfo.alliance,uid)

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_log(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')
        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        response.data.log = getModelObjs("amixer").getItemLog(mUserinfo.alliance)
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 生产珍品
    function self.action_produce(request)
        local response = self.response
        local mAmixer = getModelObjs("amixer")
        local amixerData = mAmixer.getAllAmixerData()

        for k,v in pairs(amixerData) do
            local aid = tonumber(v.aid)
            if aid > 0 then
                local amixerModel = getModelObjs("amixer",aid,false,true)
                if amixerModel then
                    amixerModel.cleanExpiredItem()
                    amixerModel.produce()
                    amixerModel.save()
                else
                    writeLog("get amixerModel failed")
                end
            end
        end

        setKfkStatus()
        response.ret = 0
        response.msg = 'Success'
        return response
    end
    
    -- function self.after() end

    return self
end

return api_amixer_item