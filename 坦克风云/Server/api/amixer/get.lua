local function api_amixer_get(request)
    local self = {
        response = {
            ret=-1,
            msg='error',
            data = {},
        },
    }

    function self.getRules()
        return {
            ["*"] = {
                _uid={"required"}
            },
        }
    end

    function self.before(request) 
        if not switchIsEnabled('btMix') then
            self.response.ret = -180
            return self.response
        end

        if self._method ~= "action_index" then
            if os.time() < (getWeeTs() + 300) then
                self.response.ret = -8469
                return self.response
            end
        end
    end

    function self.action_index(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end
        local mAmixer = getModelObjs("amixer",mUserinfo.alliance,true)
        
        response.data.bestMixer = {
            umixer = getUserObjs(request.uid,true).getModel('umixer').toArray(true),
            amixer = {
                items = mAmixer.getItems(),
                itime = mAmixer.getItime(),
            }
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    --[[
        超级装备融合数据
    ]]
    function self.action_sequip(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance,true)
        response.data.bestMixer = {
            amixer = {
                sequip = mAmixer.getSequip(),
                requests = mAmixer.getItemRequestInfo(),
            }
        }

        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_armor(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance,true)
        response.data.bestMixer = {
            amixer = {
                armor = mAmixer.getArmor(),
                requests = mAmixer.getItemRequestInfo(),
            }
        }
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_accessory(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance,true)
        response.data.bestMixer = {
            amixer = {
                accessory = mAmixer.getAccessory(),
                requests = mAmixer.getItemRequestInfo(),
            }
        }
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    function self.action_alienWeapon(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance,true)
        response.data.bestMixer = {
            amixer = {
                alienWeapon = mAmixer.getAlienWeapon(),
                requests = mAmixer.getItemRequestInfo(),
            }
        }
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- 珍品
    function self.action_items(request)
        local response = self.response
        local uid = request.uid
        local uobjs = getUserObjs(uid,true)
        local mUserinfo = uobjs.getModel('userinfo')

        if mUserinfo.alliance == 0 then
            response.ret = -102
            return response
        end

        local mAmixer = getModelObjs("amixer",mUserinfo.alliance,true)
        response.data.bestMixer = {
            amixer = {
                items = mAmixer.getItems(),
                itime = mAmixer.getItime(),
            }
        }
        
        response.ret = 0
        response.msg = 'Success'
        return response
    end

    -- function self.after() end

    return self
end

return api_amixer_get