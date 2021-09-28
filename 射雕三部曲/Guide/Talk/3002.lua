
local DEF = TalkView.DEF

return
{
    template = {
        -- 例1：删除pick-btn-1、pick-btn-2，延时0.5秒，删除传入的第一个model-tag
        remove_pick_btn = -- 步骤名为:remove_pick_btn
        {{remove = {model = {"pick-btn-1", "pick-btn-2",},},},
            {load = {tmpl   = "fade_out", params = {"pic-3"}, },},},

        -- 例2: 渐隐删除
    fade_out ={
        {action = {tag  = "@1", sync = true,
                what = {fadeout = {time = 0.2,},},},},
        {remove = {model = {"@1",},},},},

        -- 例3: 渐隐退场
    move_fade_out = {
        {action = {tag = "@1",sync = true,
                what = {spawn = {{ fadeout = {time = 0.25,},},
                         {move = {time = 0.25,by   = cc.p(500, 0), },},},},},},
        {remove = {model = {"@1",},},},},


    scale_xs = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xs1 = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0,by   = cc.p(0, 0), },},
                {scale = {time = 0,to = 0.6,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(150, 150, 150),},},},

    scale_xl = {
        {action = {tag = "@1",sync = true,what = {
                spawn = {{move = {time = 0.15,by   = cc.p(0, 0), },},
                {scale = {time = 0.15,to = 0.7,},},},},},},
        {color = {tag   = "@1",color = cc.c3b(255, 255, 255),},},},



--------------@@@@@@@@@@@@@@@

    jn = {
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", time = "@1",},},
        {remove = { model = {"talk-tag", }, },},},


    talk = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(320, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talk1 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {load = {tmpl = "scale_xl",params = {"@1"},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk0 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},},
    talk2 = {
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@2",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),sound= "@3", },},
        {remove = { model = {"talk-tag", }, },},
        {load = {tmpl = "scale_xs",params = {"@1"},},},},

    talkzm = {
        {model = { tag = "text-board1",type  = DEF.PIC,
                   file  = "jq_28.png",order = 51,
                   pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 0,},},},
        {action = {tag = "text-board",what = { fadein = {time = 0,},},},},
        {model = {tag  = "talk-tag",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = 52, text = "@1",
                    maxWidth = 550, size = 25, color = cc.c3b(244, 217, 174),time=2, },},
        {remove = { model = {"talk-tag", "text-board1",}, },},
        },


    move3 = {
        {model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
         order = 50,pos= cc.p(-140, 320),name = "@3",nameBg = "jq_27.png",
         namePos = cc.p(0.5, 0.45),},},
        {model = {tag  = "@4",type  = DEF.PIC,file  = "@5",scale = 0.7,rotation3D=cc.vec3(0,180,0),skew = true,
            order = 50,pos= cc.p(840, 320),name = "@6",nameBg = "jq_27.png",
            namePos = cc.p(0.5, 0.45),},},
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {load = {tmpl = "scale_xs1",params = {"@2"},},},
        {action = {tag  = "@1",sync = false,what = {spawn = {{move = {time = 0.3,to = cc.p(100, 320),},},},},},},
        {action = {tag  = "@4",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},},
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        {delay = {time = 0.5,},},
        },

    move1 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,
            order = 50,pos= cc.p(-140, 320),
            },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.25,to = cc.p(100, 320),},},},},},
        },
                {model = {tag  = "name-tag1",type  = DEF.LABEL, pos= cc.p(120, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    move2 = {
        {
            model = {tag  = "@1",type  = DEF.PIC,file  = "@2",scale = 0.7,rotation3D=cc.vec3(0,180,0),
            order = 50,pos= cc.p(DEF.WIDTH+140, 320),
           },
        },
        {load = {tmpl = "scale_xs1",params = {"@1"},},},
        {
            action = {tag  = "@1",what = {spawn = {{move = {time = 0.3,to = cc.p(DEF.WIDTH - 100, 320),},},},},},
        },
        {model = {tag  = "name-tag2",type  = DEF.LABEL, pos= cc.p(520, 290),order = 100, text = "@3",
                    size = 25, color = cc.c3b(255, 204, 124),time = 0.01,},},
        },

    out3= {
        {remove = { model = {"name-tag1", "name-tag2", }, },},
        {action = { tag  = "@1",sync = false,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {action = { tag  = "@2",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},},},},},
        {remove = { model = {"@1", "@2", }, },},
        },

    out1 = {
            {remove = { model = {"name-tag1", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(-100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1",}, },},
        },

    out2 = {
            {remove = { model = {"name-tag2", }, },},
        {action = { tag  = "@1",sync = true,what = {spawn = {
                   {move = {time = 0.2,to = cc.p(DEF.WIDTH+100, 320),},},
                   {fadeout = { time = 0.15,},},
                   },},},},
        {remove = { model = {"@1", }, },},
        },

    loop_map_action = {
        {action = {tag  = "@1",sync = false,what = {loop = {sequence = {{move = {time = 6,by  = cc.p(0, -100),},},
            {move = { time = 18,by   = cc.p(0, 100),},},},},},},},
        },

    bq11 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },

    bq12 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+100, 255),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},},},},},
        {color = {tag   = "@2",color = cc.c3b(180, 180, 180),},},
        {action = {tag  = "@2",what = {spawn = {{scale = {time = 0,to   = 0.6,},},
            {move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq21 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,
                  order= 50,pos= cc.p(-140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    bq22 = {
        {delay = {time = 0,},},
        {action = { tag  = "@1",what = {spawn = {{ fadeout = { time = 0,},},},},},},
        {remove = {model = {"@1",},},},
        {model = {tag= "@2",type= DEF.PIC,file= "@3",scale= 0.7,opacity= 0,rotation3D=cc.vec3(0,180,0),
                  order= 50,pos= cc.p(DEF.WIDTH+140, 320),name = "@4",nameBg = "jq_27.png",namePos = cc.p(0.5, 0.45),},},
        {action = {tag  = "@2",what = {spawn = {{fadein = { time = 0,},},{move = {time = 0,to = cc.p(DEF.WIDTH -100, 320),},},},},},},
        {delay = {time = 0.1,},},
        },


    shake = {
        {action = {tag  = "__scene__",
            --sync = true,
        what = {sequence = {
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            {move = {time = 0.02,by   = cc.p(10, -30),},},
            {move = {time = 0.02,by   = cc.p(-20, 35),},},
            {move = {time = 0.02,by   = cc.p(35, -20),},},
            {move = {time = 0.02,by   = cc.p(-25, 15),},},
            },},},},},

    -- zm1= {{
    --      model = {
    --         tag    = "@1",             type   = DEF.LABEL,
    --         pos    = cc.p("@3","@4"),  order  = 100,
    --         size   = 40,               text = "@2",
    --         color  = cc.c3b(255,255,255),parent = "@5",
    --         time   =1,
    --     },},
    -- },
    zm1= {
    {  model = { tag = "text-board1",type  = DEF.PIC,
        file  = "jq_27.png",order = 102,scale=3.6,opacity=200,
        pos   = cc.p(DEF.WIDTH / 2, 780),fadein = { time = 0.3,},},
    },
    {delay = {time = 0.3,},},
    {   model = {
            tag    = "zm-tag", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,810), order  = 105,
            size   = 28, text = "@1",maxWidth = 540,
            color  = cc.c3b(255,255,255),
            -- parent = "@5",
            time   =1,
        },},
    {delay = {time = 1.5,},},
    {remove = { model = {"zm-tag","text-board1", }, },},
    },


    mod3111={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },

    mod3={{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = 100,
            file      = "@1",         animation = "animation",
            scaleX     = "@2",        scaleY     = "@3",
            loop      = false,        speed  = 0.2,
            endRlease = true,         parent = "@6",
        },},
    },


    mod21={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = -50,
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = -60,
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,0,0),
        },},
    },


    mod31={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod32={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "pugong",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod41={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,180,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },

    mod42={
    {action = {tag  = "@1", sync = true,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "nuji",
            scale = "@5",   parent = "@6",
            loop = false,   endRlease = true,   rotation3D=cc.vec3(0,0,0),
        },},
    {delay={time=1.5},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },


    mod52={
    {action = {tag  = "@1", sync = false,what = {fadeout = {time = 0,},},},},
    {   model = {
            tag  = "pugong1",     type  = DEF.FIGURE,
            pos= cc.p("@3","@4"),    order     = 50,
            file = "@2",    animation = "zou",
            scale = "@5",   parent = "@6", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "@1",sync = false,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},
        {action = { tag  = "pugong1",sync = true,what = {move = {
                   time = "@7",by = cc.p("@8","@9"),},},},},

    -- {delay={time=0},},
    {remove = { model = {"pugong1", }, },},
    {action = {tag  = "@1", sync = true,what = {fadein = {time = 0,},},},},
    },



    jpt={
        {action = { tag  = "@1",sync = "@6",what = {jump = {
                   time = "@2",to = cc.p("@3","@4"),height="@7",times="@5",},},},},
        },

    jp1={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=10,times="@5",},},},},
        },
    jpzby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height=2,times="@5",},},},},
        },

    jptby={
        {action = { tag  = "@1",sync = true,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

     jptbytb={
        {action = { tag  = "@1",sync = false,what = {jump = {
                   time = "@2",by = cc.p("@3","@4"),height="@6",times="@5",},},},},
        },

    wp={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",      pos= cc.p("@3","@4"),},},
     },

    wps={{
         model = {
            tag  ="@1",      type   = DEF.CLIPPING,
            file = "@2",   scale    = "@5",   parent = "@6",   pos= cc.p("@3","@4"),},},
     },


    bz={
        {action = { tag  = "@1",sync = true,what = {bezier = {
                   time = "@2",to = cc.p("@3","@4"),control={cc.p("@5","@6"),cc.p("@7","@8"),},},},},},
        },

    qr1={--下浮
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {action = {tag  = "@1",sync = false,what = {fadein = {time = "@3",},},},},
        {action = {tag  = "@2",sync = false,what = {fadein = {time = "@3",},},},},
        {delay = {time = 2.5,},},
        },

    qr2={--缩放
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p(0, 0),},},
             {scale= {time = "@2",to = "@3",},},},},},},
        {delay = {time = 0.3,},},
    },




    qc1={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {move = {time = "@4",by = cc.p("@5", "@6"),},},},},},},
        {delay = {time = 0.2,},},
        {action = {tag  = "@2",sync = false,what = {fadeout = {time = "@3",},},},},
        {delay = {time = "@3",},},
        {remove = { model = {"@1", }, },},
    },



    qc2={--平移
        {action = {tag  = "@1",what = {spawn = {{move = {time = "@2",by = cc.p("@3","@4"),},},
             {scale= {time = "@2",to = 0,},},},},},},
        {delay = {time = 0.2,},},
        {remove = { model = {"@1", }, },},
    },








jt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 1.5,},},
    },

jttb={--缩放

        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",by = cc.p("@4","@5"),},},
             },},},},

    },


qg={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },

qgbz={--缩放
            {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p("@2","@3"),    order     = 50,
            file = "@1",    animation = "nuji",
            scale = 0.03,   parent = "@8",
            loop = false,   endRlease = true,  speed=0.5, rotation3D=cc.vec3(0,0,0),
        },},
        {action = {tag  = "qinggong",sync = false,what = {spawn = {{move = {time = "@4",by = cc.p("@6","@7"),},},
             {scale= {time = "@4",to = "@5",},},},},},},
        {delay = {time = 0.3,},},
    },









xbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 1480),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.8,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.12,to=4.5},},
                  {move = {time = 0.12,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.1,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.15,to=0},},
                  {move = {time = 0.15,by = cc.p(0, -200),},},},},
                  },},},},
         },


zjbq = {
    {model = {tag   = "bqqp",type  = DEF.PIC,
            scale = 0.1,pos   = cc.p(100, 400),order = 100,
            file  = "bqqp1.png",parent= "@2",},},
    {model = {tag   = "bq",type  = DEF.PIC,
            scale = 0.9,pos   = cc.p(80, 90),order = 100,
            file  = "@1",parent= "bqqp",},},
        {action = { tag  = "bqqp",sync = false,what = {sequence = {
                  {spawn = {
                  {scale = { time = 0.1,to=1},},
                  {move = {time = 0.1,by = cc.p(0, 100),},},},},
                  {delay = {time = 2.3,},},
                  -- {fadeout = { time = 0.3,},},
                  {spawn = {
                  {scale = { time = 0.1,to=0},},
                  {move = {time = 0.1,by = cc.p(0, -100),},},},},
                  },},},},
                  },






    },



---------------@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


-------------------------

    {
        model = {
            tag   = "mapbj",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = -100,
            file  = "bj.png",
        },
    },

    {
         load = {tmpl = "wp",
             params = {"clip_f","wd780.jpg","320","640","1"},},
    },


    {
        model = {
            type = DEF.CC,
            tag = "clip_1",
            parent = "clip_f",
            class = "Node",
            pos = cc.p(0, -50),
        },
    },



    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 0.9,
            pos   = cc.p(-200, 0),
            order = -99,
            file  = "huangye.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },


    -- {
    --     model = {
    --         tag   = "map2",
    --         type  = DEF.PIC,
    --         scale = 0.9,
    --         pos   = cc.p(-1728, 0),
    --         order = -99,
    --         file  = "huangye.jpg",
    --         parent= "clip_1",
    --         rotation3D=cc.vec3(0,0,0),
    --     },
    -- },


    {
        load = {tmpl = "mod21",
            params = {"yzping","hero_yinzhiping","520","-80","0.16","clip_1"},},
    },

    -- {
    --     load = {tmpl = "mod21",
    --         params = {"xlnv","hero_xiaolongnv","140","-100","0.16","clip_1"},},
    -- },

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(140,-100),    order     = 50,
            file = "hero_xiaolongnv",    animation = "shunvzhanzi",
            scale = 0.17,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},

    {
        model = {
            tag   = "mj",
            type  = DEF.PIC,
            scale = 1.5,
            pos   = cc.p(-15, 1075),
            order = 60,
            file  = "mj03.png",
            parent= "xlnv",
            rotation3D=cc.vec3(0,0,10),
        },
    },


    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-900","-100","0.16","clip_1"},},
    },

    {
        load = {tmpl = "mod22",
            params = {"lbyi","hero_nvzhu","-900","-100","0.16","clip_1"},},
    },


    {
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },

    {
        delay = {time = 0.1,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情


	{
        music = {file = "backgroundmusic4.mp3",},
    },



    {
        delay = {time = 0.2,},
    },

     {
         load = {tmpl = "jp1",
             params = {"yzping","1","-400","0","3"},},
     },

    {
        delay = {time = 0.1,},
    },




	{
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },



     {
         load = {tmpl = "move1",
             params = {"xln","xln.png",TR("小龙女")},},
     },

    -- {
    --     model = {
    --         tag   = "mj1",
    --         type  = DEF.PIC,
    --         scale = 1.5,
    --         pos   = cc.p(-15, 1075),
    --         order = 60,
    --         file  = "mj03.png",
    --         parent= "xln",
    --         rotation3D=cc.vec3(0,0,10),
    --     },
    -- },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("（过儿！是你吗？我可是你姑姑，你怎么能这样做呢？）"),148},},
     },

     {
         load = {tmpl = "move2",
             params = {"yzp","yzp.png",TR("尹志平")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yzp",TR("（龙姑娘！第一次见到你——我就不可自拔的爱上了你，每日对你朝思暮想……）"),149},},
     },

    {
        load = {tmpl = "out3",
            params = {"xln","yzp"},},
    },



     {
         load = {tmpl = "jt",
             params = {"clip_1","1.5","1","400","0"},},
     },

     {
         load = {tmpl = "jptbytb",
             params = {"lbyi","0.6","400","0","1","200"},},
     },

     {
         load = {tmpl = "jptby",
             params = {"zjue","0.6","300","0","1","200"},},
     },


     {
         load = {tmpl = "jttb",
             params = {"clip_1","1.5","1","-300","0"},},
     },

     -- {
     --     load = {tmpl = "jptbytb",
     --         params = {"zjue","1.5","300","0","3","6"},},
     -- },


    {remove = { model = {"zjue", }, },},



    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-600,-100),    order     = 49,
            file = "_run_",    animation = "zou",
            scale = 0.16,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "zjue",sync = false,what = {move = {
                   time = 1.2,by = cc.p(300,0),},},},},







    -- {action = {tag  = "zjue", sync = false,what = {fadeout = {time = 0,},},},},
    -- {   model = {
    --         tag  = "pugong0",     type  = DEF.FIGURE,
    --         pos= cc.p(-600,-100),    order     = 49,
    --         file = "_lead_",    animation = "zou",
    --         scale = 0.16,   parent = "clip_1", speed = 0.6,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
    --     },},
    --     {action = { tag  = "zjue",sync = false,what = {move = {
    --                time = 1.5,by = cc.p(300,0),},},},},
    --     {action = { tag  = "pugong0",sync = false,what = {move = {
    --                time = 1.5,by = cc.p(300,0),},},},},

    -- -- {delay={time=0},},









    {
        load = {tmpl = "mod52",
            params = {"lbyi","hero_nvzhu","-500","-100","0.16","clip_1","1.2","300","0"},},
    },

        -- {delay = {time = 1.5,},},


    {remove = { model = {"zjue", }, },},


    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","-300","-100","0.16","clip_1"},},
    },


    -- {remove = { model = {"pugong0", }, },},
    -- {action = {tag  = "zjue", sync = true,what = {fadein = {time = 0,},},},},




        {delay = {time = 0.3,},},


     {
         load = {tmpl = "move1",
             params = {"lby","lby.png",TR("洛白衣")},},
     },
     {
         load = {tmpl = "talk",
             params = {"lby",TR("无——耻——！"),150},},
     },



     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("（什么！？怎么会有人来这里……）"),151},},
     },

    {
        load = {tmpl = "out3",
            params = {"lby","xln"},},
    },





     {
         load = {tmpl = "jptby",
             params = {"yzping","0.2","-150","-20","1","60"},},
     },





     {
         load = {tmpl = "move2",
             params = {"yzp","yzp.png",TR("尹志平")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yzp",TR("你们是什么人，竟敢擅闯此地！"),152},},
     },

    {
        load = {tmpl = "out2",
            params = {"yzp"},},
    },

	-- {
 --        music = {file = "jq_bgm4.mp3",},
 --    },

     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("（这声音……这……不是过儿，我差点就……）"),153},},
     },


    {
        load = {tmpl = "out2",
            params = {"xln"},},
    },

	-- {
 --        music = {file = "jq_jy1.mp3",},
 --    },

    {action = {tag  = "yzping", sync = true,what = {fadeout = {time = 0,},},},},

    {   model = {
            tag  = "qinggong2",     type  = DEF.FIGURE,
            pos= cc.p(-30,-100),    order     = 50,
            file = "hero_yinzhiping",    animation = "pugong",
            scale = 0.16,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

        {delay = {time = 0.2,},},

    {
        sound = {file = "hero_yinzhiping_pugong.mp3",sync=false,},
    },

        {delay = {time = 0.2,},},


     {
         load = {tmpl = "jptbytb",
             params = {"zjue","0.2","-100","-600","1","60"},},
     },

     {
         load = {tmpl = "jttb",
             params = {"clip_1","1","1","500","0"},},
     },

    {
        model = {
            tag = "qinggong2",
            speed = 1.5,
        },
    },


    {action = {tag  = "lbyi", sync = true,what = {fadeout = {time = 0,},},},},

        {remove = { model = {"lbyi", }, },},

    {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p(-200,-100),    order     = 50,
            file = "hero_nvzhu",    animation = "zou",
            scale = 0.16,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.3, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "qinggong",sync = false,what = {move = {time = 0.8,by = cc.p(-500,0),},},},},




    {action = {tag  = "qinggong2",sync = true,what = {move = {time = 0.8,by = cc.p(-400,0),},},},},




        {remove = { model = {"qinggong", }, },},


    {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p(-700,-100),    order     = 50,
            file = "hero_nvzhu",    animation = "win",
            scale = 0.16,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=2, rotation3D=cc.vec3(0,0,0),
        },},

        {delay = {time = 0.5,},},


        {remove = { model = {"qinggong", }, },},

     {
         load = {tmpl = "jttb",
             params = {"clip_1","2","1","-500","0"},},
     },


    {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p(-700,-100),    order     = 50,
            file = "hero_nvzhu",    animation = "nuji",
            scale = 0.16,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},




    {   model = {
            tag  = "qinggong2",     type  = DEF.FIGURE,
            pos= cc.p(-400,-100),    order     = 50,
            file = "hero_yinzhiping",    animation = "aida",
            scale = 0.16,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.2, rotation3D=cc.vec3(0,180,0),
        },},

        -- {model = {tag  = "jnmusic",type  = DEF.LABEL, pos= cc.p(DEF.WIDTH / 2, 250),order = -100, text = " ",
        --             maxWidth = 0, size = 25, color = cc.c3b(255, 255, 255),sound= "hero_nvzhu_nuji.mp3", },},


    {action = {tag  = "qinggong",sync = false,what = {move = {time = 2,by = cc.p(400,0),},},},},

        {delay = {time = 0.2,},},

    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },

        {delay = {time = 0.4,},},

        {remove = { model = {"qinggong2", }, },},

    {   model = {
            tag  = "qinggong2",     type  = DEF.FIGURE,
            pos= cc.p(-400,-100),    order     = 50,
            file = "hero_yinzhiping",    animation = "aida",
            scale = 0.16,   parent = "clip_1",
            loop = false,   endRlease = true,  speed=0.2, rotation3D=cc.vec3(0,180,0),
        },},


    {action = {tag  = "qinggong2",sync = true,what ={ spawn={{bezier = {time = 1,to = cc.p(240,0),
                                 control={cc.p(-300,200),cc.p(0,500),}
    },},
    {rotate = {to = cc.vec3(0, 180, 90),time = 1,},},},
    },},},


        {remove = { model = {"qinggong2", }, },},


        {remove = { model = {"qinggong", }, },},




    {
        load = {tmpl = "mod22",
            params = {"lbyi","hero_nvzhu","-300","-100","0.16","clip_1"},},
    },

    {
       delay = {time = 0.3,},
    },





     {
         load = {tmpl = "move1",
             params = {"lby","lby.png",TR("洛白衣")},},
     },



     {
         load = {tmpl = "talk",
             params = {"lby",TR("不堪一击————"),154},},
     },

    {
        load = {tmpl = "out1",
            params = {"lby"},},
    },



    {
        music = {file = "jq_gql.mp3",},
    },


     {
         load = {tmpl = "jt",
             params = {"clip_1","1.5","3","-550","-200"},},
     },
    {
       delay = {time = 0.3,},
    },




    {
        model = {
            tag   = "mj1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-15, 1075),
            order = 60,
            file  = "mj02.png",
            parent= "xlnv",opacity=0,
            rotation3D=cc.vec3(0,180,0),
        },
    },


    {action = {tag  = "mj1",sync = false,what ={ spawn={{scale= {time = 1,to = 1,},},
    {bezier = {time = 2,to = cc.p(-1250,-100),
                                 control={cc.p(-15,1000),cc.p(-50,800),}
    },},},
    },},},

    {action = {tag  = "mj",sync = false,what ={ spawn={{scale= {time = 1,to = 1.5,},},
    {bezier = {time = 2,to = cc.p(-1250,-100),
                                 control={cc.p(-15,1000),cc.p(-50,800),}
    },},},
    },},},

    {
       delay = {time = 0.4,},
    },

    {action = {tag  = "mj1", sync = false,what = {fadein = {time = 0,},},},},

    {action = {tag  = "mj", sync = true,what = {fadeout = {time = 0,},},},},

    {
       delay = {time = 1,},
    },



    -- {
    --     load = {tmpl = "mod21",
    --         params = {"xlnv","hero_xiaolongnv","140","-100","0.16","clip_1"},},
    -- },






     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },



     {
         load = {tmpl = "talk",
             params = {"xln",TR("（过儿，你不是说过要永远陪在我身边吗，如今我差点辱没贼人之手，你——却又在哪里……）"),155},},
     },


    {
        load = {tmpl = "out2",
            params = {"xln"},},
    },

-- --小龙女面纱脱落特效




    {
       delay = {time = 0.8,},
    },


     {
         load = {tmpl = "jt",
             params = {"clip_1","1.5","1","550","200"},},
     },

    {
       delay = {time = 0.3,},
    },



	-- {
 --        music = {file = "jianghu2.mp3",},
 --    },


    {
        load = {tmpl = "mod52",
            params = {"lbyi","hero_nvzhu","-300","-100","0.16","clip_1","1","200","0"},},
    },






     -- {
     --     load = {tmpl = "move1",
     --         params = {"lby","lby.png","洛白衣"},},
     -- },



     -- {
     --     load = {tmpl = "talk",
     --         params = {"lby",TR("你就是小龙女——！？"),"1005.mp3"},},
     -- },

     -- {
     --     load = {tmpl = "talk",
     --         params = {"xln",TR("……"),"139.mp3"},},
     -- },






     {
         load = {tmpl = "jptby",
             params = {"zjue","0.5","200","600","1","60"},},
     },




    -- {
    --     load = {tmpl = "out2",
    --         params = {"xln"},},
    -- },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("师父，她被点了穴！"),23},},
     },

    {
        load = {tmpl = "out1",
            params = {"zj"},},
    },




    -- {action = {tag  = "lbyi", sync = true,what = {fadeout = {time = 0,},},},},


    {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p(-100,-100),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.16,   parent = "clip_1", opacity=0,
            loop = true,   endRlease = false,  speed=3, rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 1,},
    },



    {action = {tag  = "qinggong", sync = true,what = {fadein = {time = 0,},},},},

    {action = {tag  = "lbyi", sync = true,what = {fadeout = {time = 0,},},},},






    {
        model = {
            tag = "qinggong",
            speed = -1.5,
        },
    },



        {delay = {time = 0.4,},},

    {
        sound = {file = "forging_dig.mp3",sync=false,},
    },





    {
       delay = {time = 0.3,},
    },









    {
        model = {
            tag = "qinggong",
            speed = 1.5,
        },
    },


    {   model = {
            tag  = "qinggong3",     type  = DEF.FIGURE,
            pos= cc.p(140,-100),    order     = 50,
            file = "hero_xiaolongnv",    animation = "aida",
            scale = 0.16,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.66, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "xlnv", sync = true,what = {fadeout = {time = 0,},},},},

    {remove = { model = {"xlnv", }, },},
    {
       delay = {time = 0.7,},
    },







    {remove = { model = {"qinggong", }, },},


    {action = {tag  = "lbyi", sync = true,what = {fadein = {time = 0,},},},},

    {
       delay = {time = 0.4,},
    },

	-- {
 --        music = {file = "jq_gql.mp3",},
 --    },


    {
        load = {tmpl = "mod21",
            params = {"xlnv","hero_xiaolongnv","140","-100","0.16","clip_1"},},
    },



    {remove = { model = {"qinggong3", }, },},



    {   model = {
            tag  = "qinggong2",     type  = DEF.FIGURE,
            pos= cc.p(400,-100),    order     = 50,
            file = "hero_yinzhiping",    animation = "aida",
            scale = 0.16,   parent = "clip_1",opacity=0,
            loop = false,   endRlease = true,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.3,},
    },

    {
        model = {
            tag = "qinggong2",
            speed = 0.3,
        },
    },

    {action = {tag  = "qinggong2", sync = true,what = {fadein = {time = 0,},},},},


-- --解穴特效，小龙女跌倒


     {
         load = {tmpl = "jt",
             params = {"clip_1","0.5","1","-250","0"},},
     },

    {remove = { model = {"xlnv", }, },},

    {
        load = {tmpl = "mod22",
            params = {"xlnv","hero_xiaolongnv","140","-100","0.16","clip_1"},},
    },






     {
         load = {tmpl = "move2",
             params = {"yzp","yzp.png",TR("尹志平")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yzp",TR("龙姑娘——！你听我解释！"),156},},
     },

    {
        load = {tmpl = "out2",
            params = {"yzp"},},
    },


    {remove = { model = {"xlnv", }, },},

    {
        load = {tmpl = "mod21",
            params = {"xlnv","hero_xiaolongnv","140","-100","0.16","clip_1"},},
    },




     {
         load = {tmpl = "move1",
             params = {"lby","lby.png",TR("洛白衣")},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("交出玉女心经！"),157},},
     },


    {remove = { model = {"yzping", }, },},


    {
        load = {tmpl = "mod21",
            params = {"yzping","hero_yinzhiping","400","-100","0.16","clip_1"},},
    },
    {remove = { model = {"qinggong2", }, },},










-- --小龙女飞走，主角拦住白衣



    {   model = {
            tag  = "qinggong",     type  = DEF.FIGURE,
            pos= cc.p(-100,-100),    order     = 50,
            file = "hero_nvzhu",    animation = "pugong",
            scale = 0.16,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "lbyi", sync = true,what = {fadeout = {time = 0,},},},},


        {delay = {time = 0.2,},},

    {
        sound = {file = "hero_nvzhu_pugong.mp3",sync=false,},
    },

    {
       delay = {time = 0.2,},
    },



    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },
     {
         load = {tmpl = "jptby",
             params = {"zjue","0.3","100","0","1","60"},},
     },


    {remove = { model = {"zjue", }, },},

    {
        load = {tmpl = "mod21",
            params = {"zjue","_lead_","50","-100","0.16","clip_1"},},
    },


    {
       delay = {time = 0.3,},
    },



    {
        model = {
            tag = "qinggong",
            speed = -1,
        },
    },

    {
       delay = {time = 1,},
    },

    {remove = { model = {"qinggong", }, },},

    {action = {tag  = "lbyi", sync = true,what = {fadein = {time = 0,},},},},



    {remove = { model = {"xlnv", }, },},
    {
        load = {tmpl = "mod22",
            params = {"xlnv","hero_xiaolongnv","140","-100","0.16","clip_1"},},
    },
    {   model = {
            tag  = "qinggong4",     type  = DEF.FIGURE,
            pos= cc.p(140,-100),    order     = 50,
            file = "hero_xiaolongnv",    animation = "win",
            scale = 0.16,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1.25, rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "xlnv", sync = true,what = {fadeout = {time = 0,},},},},

    {remove = { model = {"xlnv", }, },},



    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "qinggong4",sync = true,what ={ spawn={{bezier = {time = 0.8,to = cc.p(600,200),
                                 control={cc.p(140,-100),cc.p(200,250),}
    },},},
    },},},

    {remove = { model = {"qinggong4", }, },},





	-- {
 --        music = {file = "jq_bgm4.mp3",},
 --    },




     {
         load = {tmpl = "talk",
             params = {"lby",TR("你干嘛拦着我！？"),158},},
     },



     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("哎呀！师父！女人何苦为难女人呢，龙姑娘正在伤心，咱们就别去做那恶人了！"),24},},
     },

     {
         load = {tmpl = "talk",
             params = {"lby",TR("你？！"),159},},
     },

    {remove = { model = {"zjue", }, },},

    {
        load = {tmpl = "mod22",
            params = {"zjue","_lead_","50","-100","0.16","clip_1"},},
    },


     {
         load = {tmpl = "talk",
             params = {"zj",TR("我们先把这个不守清规的臭道士给解决了，省得在这里看着碍眼！"),25},},
     },

    -- {
     --    load = {tmpl = "talk",
     --        params = {"lby",TR("他是无关之人，不必理会他！让他滚就是了！"),"1005.mp3"},},
   --  },


    {remove = { model = {"yzping", }, },},

    {
        load = {tmpl = "mod22",
            params = {"yzping","hero_yinzhiping","400","-100","0.16","clip_1"},},
    },


     {
         load = {tmpl = "jptby",
             params = {"yzping","0.5","300","0","1","200"},},
     },


--尹志平离开


   --  {
    --     load = {tmpl = "talk",
     --        params = {"zj",TR("师父，这家伙这么可恶，难道就这样放过他！"),"139.mp3"},},
     --},


    {
        load = {tmpl = "out3",
            params = {"lby","zj"},},
    },
    -- {
    --    delay = {time = 5,},
    -- },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
