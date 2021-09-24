--[[
    routeCfg按request.cmd注册一组过滤器,before和after
    before组将在api运行前先运行,after组将在api执行完成后运行

    如果运行before组过滤器时有返回值,并且ret不为0,api将不会执行,但routeCfg中配置的after过滤器会继续执行
    after组运行时的参数是before或api执行后的返回值
    
    过滤器可按cmd层级来配置,有相同过滤器时下级的会覆盖上级的过滤器:
        admin.test.getUser > admin.test > admin > All
    下级会自动继承所有上级设置的过滤器:
        admin.test.getUser 将会获得 admin.test, admin, All 中的所有过滤器
        admin.test 将会获得 admin, All中的过滤器
    新的cmd组成为目录.文件.方法,如果为目录配置了过滤器,则该目录下的所有文件和方法都会拥有这组过滤器

    [ALL]是全局过滤器,所有的API都会继承

    过滤器方法写在lib/filter文件中,这里只配置过滤器名
    如果配置是一个table,则第1个元素是过滤器名,后面的元素会做为一个table成为filter的参数

    例：
    ["ALL"] = {before={"auth"},after={}},

    ["admin"]={
        before = {"useEquipCheck"}, -- auth(request),useEquipCheck(request)
        after = {},
    },

    ["admin_test"]={
        before={,{"troopsCheck",100,20}}, -- auth(request),useEquipCheck(request),troopsCheck(request,{100,20})
        after={"useEquipCheckafter"} useEquipCheckafter(response)
    },

    ["admin_test_getUser"]={
        before={{"troopsCheck",200,10}}, -- auth(request),useEquipCheck(request),troopsCheck(request,{200,10})覆盖admin.test的troopsCheck
        after={} -- useEquipCheckafter(response)
    },

]]
local routeCfg = {
    -- ["ALL"] = {before={},after={}},

    ["admin"]={
        before = {"setAdminLog"},
        after = {},
    },

    ["pay_processorder"] = {
        before = {"checkRayapiToken"}
    },

    ["achallenge_battle"]={
        before = {"usePlaneCheck"},
    },

    ["across_setinfo"]={
        before = {"usePlaneCheck"},
    },

    ["alienmine_attack"]={
        before = {"usePlaneCheck"},
    },

    ["alliancewarnew_setinfo"]={
        before = {"usePlaneCheck"},
    },

    ["areawar_setinfo"]={
        before = {"usePlaneCheck"},
    },

    ["boss_setinfo"]={
        before = {"usePlaneCheck"},
    },

    ["achallenge_battleboss"]={
        before = {"usePlaneCheck"},
    },

    ["challenge_battle"]={
        before = {"usePlaneCheck"},
    },

    ["echallenge_battle"]={
        before = {"usePlaneCheck"},
    },

    ["expedition_battle"]={
        before = {"usePlaneCheck"},
    },

    ["weapon_swchallenge"]={
        before = {"usePlaneCheck"},
    },

    ["military_settroops"]={
        before = {"usePlaneCheck"},
    },

    ["troop_attack"]={
        before = {"usePlaneCheck"},
    },

    ["troop_setdefense"]={
        before = {"usePlaneCheck"},
    },

    ["userwar_apply"]={
        before = {"usePlaneCheck"},
    },

     ["active_newyeareva"]={
        before = {"usePlaneCheck"},
    },

    ["worldwar_setinfo"]={
        before = {"usePlaneCheck"},
    },

    ["areateamwar_setinfo"]={
        before = {"usePlaneCheck"},
    },

    ["platwar_setinfo"]={
        before = {"usePlaneCheck"},
    },

    ["weapon_battle"]={
        before = {"usePlaneCheck"},
    },

    ["hchallenge_battle"]={
        before = {"usePlaneCheck"},
    },

    ["weapon_settroops"]={
        before = {"usePlaneCheck"},
    },

    ["alienweapon_attack"]={
        before = {"usePlaneCheck"},
    },

    ["alienweapon_battle"]={
        before = {"usePlaneCheck"},
    },

    ["alienweapon_seabattle"]={
        before = {"usePlaneCheck"},
    },

    ["sequip"] = {
        before = {{"switchsCheck","sequip"},}
    },

    ["oceanexpedition_set_troops"]={
        before = {"troopsCheck","usePlaneCheck"},
    },

    ["greatroute_set_troops"]={
        before = {"troopsCheck","usePlaneCheck"},
    },

}

return routeCfg