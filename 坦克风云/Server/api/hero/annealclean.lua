-- 将领试炼
function api_hero_annealclean(request)
    local response = {
        ret=0,
        msg='sucess',
        data = {},
    }

    local mAnneal = loadModel("model.heroanneal", {})
    local cnt = mAnneal.clearAnnealData()

    if cnt > 0 then
    	writeLog({cnt=cnt}, 'cleanneal')
    end
    
    return response
end