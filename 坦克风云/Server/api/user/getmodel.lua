-- 获取指定模块数据
-- 战力引导优化
-- chenyunhe
function api_user_getmodel(request)
    local response = {
        ret=-1,
        msg='error',
        data = {},
    }

    local uid = request.uid
    local models = request.params.models
    if uid == nil or models==nil then
        response.ret = -102
        return response
    end

    local uobjs = getUserObjs(uid,true)
    if #models==0 then
        response.ret =-102
    end
   -- 模块名称顺序固定 {"accessory","equip","armor","alien"}
   for _,v in pairs(models) do
       -- 获取使用的配件信息
       if v==1 then
           local mModel = uobjs.getModel("accessory")
           response.data.accessory={}
           response.data.accessory.used = mModel.used
       elseif v==2 then
           -- 获取将领装备信息
           local mModel = uobjs.getModel("equip")
           response.data.equip={}
           response.data.equip.info = mModel.info
       elseif v==3 then
           -- 获取装甲信息
           local mModel = uobjs.getModel("armor")
           response.data.armor={}
           response.data.armor.info = mModel.info
           response.data.armor.used = mModel.used
       elseif v==4 then
           -- 异星科技
           local mModel = uobjs.getModel("alien")
           response.data.alien={}
           response.data.alien.used = mModel.used
           response.data.alien.info = mModel.info
       elseif v==5 then
           -- 徽章
           local mModel = uobjs.getModel('badge')
           response.data.badge={}
           response.data.badge.used = mModel.used
           response.data.badge.info = mModel.info
       end


   end
    response.data.fcr=getMyFcRanking(uid)-- 玩家的排名
    response.ret=0
    response.msg ='Success'
    return response

end
