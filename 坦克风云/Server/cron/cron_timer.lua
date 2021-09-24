-- 在本地中执行lua定时请求,不适合做有push消息的脚本请求
do
    print("\n\n------------lua cmd:",cmd,"----------\n")

    if #arg >= 2 then
        package.path = arg[2] .. "/../?.lua;" .. package.path
        require "dispatch"
        local cmd=arg[1]
        local response =  dispatch(cmd)
        print (response)
    else
        print("params invalid")
    end
end