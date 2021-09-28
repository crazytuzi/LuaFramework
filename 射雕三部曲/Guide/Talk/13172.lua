
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


    zm= {
    {   model = {
            tag    = "@2", type   = DEF.LABEL,
            pos    = cc.p(DEF.WIDTH / 2,"@2"), order  = 105,
            size   = 25, text = "@1",
            maxWidth = 500,
            color  = cc.c3b(244, 217, 174),
            -- parent = "@5",
            time   =1.5,
        },},
    {delay = {time = 0.5,},},
    -- {remove = { model = {"zm-tag", }, },},
    },



    mod3111={
	     {remove = { model = {"texiao", }, },},
	{
        model = {
            tag       = "texiao",     type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),     order     = 100,
            file      = "@1",         animation = "animation",
            scale     = "@2",         loop      = false,
            endRlease = true,         parent = "@5",
        },},
    },


    modbj1={
    {
        model = {
            tag   = "@1",
            type  = DEF.PIC,
            scale = "@3",
            pos   = cc.p("@4","@5"),
            order = "@6",
            file  = "@2",
            parent= "@7",
            rotation3D=cc.vec3("@8","@9","@10"),
        },
    },},
    modbj2={
	{
        model = {
            tag       = "@1",     type      = DEF.FIGURE,
            pos= cc.p("@4","@5"),     order     = "@6",
            file      = "@2",         animation = "animation",
            scale     = "@3",         loop      = true,
            endRlease = false,         parent = "@7",  speed = "@11", rotation3D=cc.vec3("@8","@9","@10"),
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
            pos= cc.p("@3","@4"),  order     = "@7",
            file      = "@2",      animation = "daiji",
            scale     = "@5",      loop      = true,
            endRlease = false,     parent = "@6",     rotation3D=cc.vec3(0,180,0),
        },},
    },
    mod22={{
        model = {
            tag       = "@1",      type      = DEF.FIGURE,
            pos= cc.p("@3","@4"),  order     = "@7",
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








jtt={--缩放
        {action = {tag  = "@1",what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
    },

jtttb={--缩放
        {action = {tag  = "@1",sync = false,what = {spawn = {
             {scale= {time = "@2",to = "@3",},},{move = {time = "@2",to = cc.p("@4","@5"),},},
             },},},},
        -- {delay = {time = 0.2,},},
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
             },},},},},



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
            pos = cc.p(0, -300),
            -- scale =0.8,
        },
    },

    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 100),
            order = -99,
            file  = "fudi.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },
    {
        model = {
            tag   = "map2",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(1920, 100),
            order = -99,
            file  = "fudi.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,180,0),
        },
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
        music = {file = "backgroundmusic1.mp3",},
    },


     {
         load = {tmpl = "zm",
             params = {TR("李莫愁一心抢夺玉女心经，"),"900"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("小龙女无奈放下古墓的断龙石，"),"850"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("在断龙石落下的最后一刻，"),"800"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("杨过冲入古墓之中，"),"750"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("选择与重伤的小龙女同生共死。"),"700"},},
     },


    {delay = {time = 0.5,},},





     {
         load = {tmpl = "zm",
             params = {TR("面对去而复返的杨过，"),"600"},},
     },
     {
         load = {tmpl = "zm",
             params = {TR("小龙女心中满是欢喜，"),"550"},},
     },
     {
         load = {tmpl = "zm",
             params = {TR("躺在杨过的怀中，"),"500"},},
     },
     {
         load = {tmpl = "zm",
             params = {TR("小龙女心中柔肠千结，"),"450"},},
     },
     {
         load = {tmpl = "zm",
             params = {TR("似有千般言语想要倾诉……"),"400"},},
     },


    {delay = {time = 2.4,},},

    {remove = { model = {"900", "850", "800","750", "700", }, },},

    {remove = { model = {"600", "550", "500", "450", "400",}, },},


    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(910,225),    order     = 95,
            file = "hero_yangguo_hei",    animation = "baofu",
            scale = 0.15,   parent = "clip_1", speed = 0.05,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},
    {
        model = {
            tag   = "xue1",
            type  = DEF.PIC,
            scaleX = 0.4,scaleY = 0.5,
            pos   = cc.p(-220, 400),
            order = 100,
            file  = "xue1.png",
            parent= "yguo",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    -- {
    --     model = {
    --         tag   = "xue2",
    --         type  = DEF.PIC,
    --         scaleX = 0.6,scaleY = 0.5,
    --         pos   = cc.p(-217, 400),
    --         order = 100,
    --         file  = "xue2.png",
    --         parent= "yguo",
    --         rotation3D=cc.vec3(0,0,0),
    --     },
    -- },


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","1","-900","-300"},},
     },
    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.8","3","-2800","-1000"},},
     },


	{
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move2",
             params = {"xln","xln.png",TR("小龙女")},},
     },






    -- {
    --     model = {
    --         tag   = "xue",
    --         type  = DEF.PIC,
    --         scale = 0.3,
    --         pos   = cc.p(500, 600),
    --         order = 50,
    --         file  = "xueji.png",
    --         parent= "xln.png",
    --         rotation3D=cc.vec3(0,0,-40),
    --     },
    -- },


    {
        model = {
            tag   = "xue3",
            type  = DEF.PIC,
            scaleX = 0.25,scaleY = 0.3,
            pos   = cc.p(427, 664),
            order = 100,
            file  = "xue1.png",
            parent= "xln", opacity=155,
            rotation3D=cc.vec3(0,0,0),
        },
    },
    -- {
    --     model = {
    --         tag   = "xue4",
    --         type  = DEF.PIC,
    --         scaleX = 0.25,scaleY = 0.3,
    --         pos   = cc.p(428, 664),
    --         order = 100,
    --         file  = "xue2.png",
    --         parent= "xln",opacity=155,
    --         rotation3D=cc.vec3(0,0,0),
    --     },
    -- },


     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿，我这内伤，恐怕永远也好不了了！"),"3039.mp3"},},
     },

     {
         load = {tmpl = "move1",
             params = {"yg","yg.png",TR("杨过")},},
     },






     {
         load = {tmpl = "talk",
             params = {"yg",TR("不会的，我一定会想办法治好姑姑的。"),"3040.mp3"},},
     },



     {
         load = {tmpl = "talk1",
             params = {"xln",TR("师父曾经对我说过，修炼这种武功必须断绝七情六欲……"),"3041.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"xln",TR("如果，对人动了真情，不但武功大损，还会有性命之忧！"),"3042.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑，你别担心了，你一定会好起来的。"),"3043.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿，你喜不喜欢姑姑？"),"3044.mp3"},},
     },


     {
         load = {tmpl = "talk",
             params = {"yg",TR("过儿当然喜欢姑姑，当今世上只有姑姑对过儿最好！"),"3045.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("假如日后——有另外的女子像姑姑这样对你好，你会不会……"),"3046.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("总之不管谁对我好，我就对谁好！"),"3047.mp3"},},
     },



     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","1.5","-1500","-600"},},
     },




    {remove = { model = {"yguo", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(900,225),    order     = 95,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.8,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {   model = {
            tag  = "xlnv",     type  = DEF.FIGURE,
            pos= cc.p(1050,225),    order     = 95,
            file = "hero_xiaolongnv",    animation = "shunvzhanzi",
            scale = 0.15,   parent = "clip_1", speed = 1,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
        model = {
            tag   = "xue2",
            type  = DEF.PIC,
            scaleX = 0.6,scaleY = 0.5,
            pos   = cc.p(-10, 1073),
            order = 100,
            file  = "xue1.png",
            parent= "xlnv", opacity=205,
            rotation3D=cc.vec3(0,0,0),
        },
    },



     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿，你……"),"3048.mp3"},},
     },

    -- {remove = { model = {"yguo", }, },},
    -- -- {remove = { model = {"xlnv", }, },},
    -- {   model = {
    --         tag  = "yguo",     type  = DEF.FIGURE,
    --         pos= cc.p(910,225),    order     = 95,
    --         file = "hero_yangguo_hei",    animation = "daiji",
    --         scale = 0.15,   parent = "clip_1", speed = 0.9,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
    --     },},

    -- {   model = {
    --         tag  = "xlnv",     type  = DEF.FIGURE,
    --         pos= cc.p(910,225),    order     = 95,
    --         file = "hero_xiaolongnv",    animation = "shunvzhanzi",
    --         scale = 0.15,   parent = "clip_1", speed = 0.8,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
    --     },},



     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑，是不是过儿又说错话了？"),"3049.mp3"},},
     },

    -- {remove = { model = {"xlnv", }, },},
    -- {   model = {
    --         tag  = "xlnv",     type  = DEF.FIGURE,
    --         pos= cc.p(1000,225),    order     = 95,
    --         file = "hero_xiaolongnv",    animation = "qingshang",
    --         scale = 0.15,   parent = "clip_1", speed = 0.5,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
    --     },},



     {
         load = {tmpl = "talk",
             params = {"xln",TR("假如以后，你会喜欢别的女子，那你还是别喜欢我吧！"),"3050.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("过儿明白的，姑姑只对过儿好，过儿也会只对姑姑好的！"),"3051.mp3"},},
     },


    -- {remove = { model = {"xlnv", }, },},
    -- {   model = {
    --         tag  = "xlnv",     type  = DEF.FIGURE,
    --         pos= cc.p(1000,225),    order     = 95,
    --         file = "hero_xiaolongnv",    animation = "qingshang",
    --         scale = 0.15,   parent = "clip_1", speed = 0.5,
    --         loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
    --     },},


     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿……姑姑还是希望，过儿立下一个誓言！"),"3052.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("立什么誓言？"),"3053.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"xln",TR("你以后只可以喜欢姑姑一个人……假如你喜欢上另外的女子的话——就要死在我的手上！"),"3054.mp3"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"yg",TR("好，我杨过发誓，青天在上，弟子杨过——"),"3055.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"yg",TR("今生今世只会喜欢姑姑一个人，倘若他日变心的话，不需要姑姑动手，弟子杨过也会立刻自刎而死！"),"3056.mp3"},},
     },


    {
        model = {
            tag   = "lei1",
            type  = DEF.PIC,
            scaleX = 0.6,scaleY = 0.4,
            pos   = cc.p(-40, 1084),
            order = 100,
            file  = "yanlei.png",color = cc.c3b(255, 204, 124),
            parent= "xlnv", opacity=255,
            rotation3D=cc.vec3(0,0,0),
        },
    },


    {
        model = {
            tag   = "lei2",
            type  = DEF.PIC,
            scaleX = 0.6,scaleY = 0.4,
            pos   = cc.p(5, 1084),
            order = 100,
            file  = "yanlei.png",color = cc.c3b(255, 204, 124),
            parent= "xlnv", opacity=255,
            rotation3D=cc.vec3(0,0,0),
        },
    },


     {
         load = {tmpl = "talk",
             params = {"xln",TR("过儿……"),"3057.mp3"},},
     },

     -- {
     --     load = {tmpl = "jtt",
     --         params = {"clip_1","0.8","4","-4200","-1400"},},
     -- },

     -- {
     --     load = {tmpl = "jtt",
     --         params = {"clip_1","0.8","8","-8400","-3000"},},
     -- },


    {remove = { model = {"yguo", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(900,225),    order     = 90,
            file = "hero_yangguo_hei",    animation = "zou",
            scale = 0.15,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},
        {action = { tag  = "yguo",sync = true,what = {move = {
                   time = 0.6,by = cc.p(110,0),},},},},
    {remove = { model = {"yguo", }, },},

    {   model = {
            tag  = "yguo",     type  = DEF.FIGURE,
            pos= cc.p(1010,225),    order     = 90,
            file = "hero_yangguo_hei",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.9,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑，你怎么哭了？你不要哭！"),"3058.mp3"},},
     },

     {
         load = {tmpl = "talk1",
             params = {"xln",TR("我不是哭，我是高兴！"),"3059.mp3"},},
     },

     {
         load = {tmpl = "talk2",
             params = {"xln",TR("过儿，你用力抱着姑姑！"),"3060.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yg",TR("姑姑……"),"3061.mp3"},},
     },












    {
        load = {tmpl = "out3",
            params = {"yg","xln"},},
    },

    {
       delay = {time = 0.1,},
    },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 0),},
    },

    {
	   delay = {time = 0.1,},
	},
}
