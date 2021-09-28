
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
        model = {tag   = "curtain-window",type  = DEF.WINDOW,
                 size  = cc.size(DEF.WIDTH, 0),order = 100,
                 pos   = cc.p(DEF.WIDTH / 2, DEF.HEIGHT * 0.5),},
    },


    {
        delay = {time = 0.1,},
    },

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
            tag   = "map0",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(-1920, 0),
            order = -99,
            file  = "zongnanshan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
        },
    },

    {
        model = {
            tag   = "map1",
            type  = DEF.PIC,
            scale = 1,
            pos   = cc.p(0, 0),
            order = -99,
            file  = "zongnanshan.jpg",
            parent= "clip_1",
            rotation3D=cc.vec3(0,0,0),
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
        music = {file = "battle5.mp3",},
    },


     {
         load = {tmpl = "zm",
             params = {TR("一路追寻武穆遗书，"),"800"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("你来到了铁掌帮禁地——铁掌峰，"),"750"},},
     },

     {
         load = {tmpl = "zm",
             params = {TR("此刻，郭靖与黄蓉被杨康逼上了悬崖……"),"700"},},
     },


    {delay = {time = 0.5,},},

    {remove = { model = {"800", "750", "700",},},},


     {
         load = {tmpl = "jtt",
             params = {"clip_1","0","0.7","85","-200"},},
     },

    {
        action = { tag  = "curtain-window",
            sync = true,time = 0.6,
            size = cc.size(DEF.WIDTH, 860),},
    },


----正式剧情

    {
        music = {file = "battle1.mp3",},
    },

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(-400,400),    order     = 42,
            file = "hero_huangrong",    animation = "pose",
            scale = 0.06,   parent = "clip_1", speed = 0.6,
            loop = false,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "hrong",sync = false,what ={ spawn={{scale= {time = 0.8,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(50,0),
                                 control={cc.p(-400,400),cc.p(-100,350),}
    },},},
    },},},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-450,400),    order     = 42,
            file = "hero_guojing",    animation = "pose",
            scale = 0.06,   parent = "clip_1", speed = 0.6,
            loop = false,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "gjing",sync = false,what ={ spawn={{scale= {time = 0.8,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(-100,0),
                                 control={cc.p(-450,400),cc.p(-200,350),}
    },},},
    },},},


    {
       delay = {time = 0.5,},
    },


    {remove = { model = {"hrong", }, },},
    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(50,0),    order     = 42,
            file = "hero_huangrong",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 42,
            file = "hero_guojing",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {
       delay = {time = 0.1,},
    },


    {remove = { model = {"hrong", }, },},
    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(50,0),    order     = 42,
            file = "hero_huangrong",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.95","25","-200"},},
     },

    {
       delay = {time = 0.5,},
    },


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },


     {
         load = {tmpl = "move1",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("蓉儿，你怎么样了？"),"1183.mp3"},},
     },

    {remove = { model = {"hrong", }, },},
    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(50,0),    order     = 42,
            file = "hero_huangrong",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "move2",
             params = {"hr","hr.png",TR("黄蓉")},},
     },

     {
         load = {tmpl = "talk",
             params = {"hr",TR("靖哥哥，你快走，别管我，武穆遗书决不能落入金人手中……"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"gj","hr"},},
    },


    {
       delay = {time = 0.1,},
    },


      {remove = { model = {"text-board", },},},

    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.8","600","-200"},},
     },

    {
       delay = {time = 0.5,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-800,400),    order     = 42,
            file = "hero_yangkang",    animation = "pose",
            scale = 0.08,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "ykang",sync = false,what ={ spawn={{scale= {time = 1.5,to = 0.15,},},
    {bezier = {time = 1.3,to = cc.p(-450,0),
                                 control={cc.p(-800,400),cc.p(-400,350),}
    },},},
    },},},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.3","0.85","200","-200"},},
     },

    {
       delay = {time = 0.9,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"ykang", }, },},
    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-450,0),    order     = 42,
            file = "hero_yangkang",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 42,
            file = "hero_guojing",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.2,},
    },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move1",
             params = {"yk","yk.png",TR("杨康")},},
     },

     {
         load = {tmpl = "talk",
             params = {"yk",TR("郭靖，快把武穆遗书交出来！否则你俩死无全尸！"),"1183.mp3"},},
     },

     {
         load = {tmpl = "move2",
             params = {"gj","gj.png",TR("郭靖")},},
     },

     {
         load = {tmpl = "talk",
             params = {"gj",TR("康弟，绝不能把武穆遗书交给金人，否则汉人就要完蛋了！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"gj"},},
    },

     {
         load = {tmpl = "move2",
             params = {"hr","hr.png",TR("黄蓉")},},
     },

     {
         load = {tmpl = "talk",
             params = {"hr",TR("靖哥哥，别劝了，他已经无药可救了。"),"1183.mp3"},},
     },

     {
         load = {tmpl = "talk",
             params = {"yk",TR("既然你们执迷不悟，就别怪我不念旧情了！给我了杀了他们！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"yk","hr"},},
    },

    {
       delay = {time = 0.1,},
    },

      {remove = { model = {"text-board", },},},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {   model = {
            tag  = "qqzhang",     type  = DEF.FIGURE,
            pos= cc.p(-800,300),    order     = 41,
            file = "hero_qiuqianzhang",    animation = "pose",
            scale = 0.08,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "qqzhang",sync = false,what ={ spawn={{scale= {time = 1,to = 0.13,},},
    {bezier = {time = 0.8,to = cc.p(-325,100),
                                 control={cc.p(-800,300),cc.p(-400,300),}
    },},},
    },},},


    {remove = { model = {"qqzhang", },},},
    {   model = {
            tag  = "qqzhang",     type  = DEF.FIGURE,
            pos= cc.p(-325,100),    order     = 41,
            file = "hero_qiuqianzhang",    animation = "daiji",
            scale = 0.13,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-800,100),    order     = 43,
            file = "hero_qiuqianzhang",    animation = "pose",
            scale = 0.08,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "oyke",sync = false,what ={ spawn={{scale= {time = 1,to = 0.15,},},
    {bezier = {time = 0.8,to = cc.p(-350,-100),
                                 control={cc.p(-800,100),cc.p(-425,150),}
    },},},
    },},},


    {remove = { model = {"oyke", },},},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-350,-100),    order     = 43,
            file = "hero_ouyangke",    animation = "daiji",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.4,},
    },

     {
         load = {tmpl = "jtt",
             params = {"clip_1","0.5","0.95","-425","-420"},},
     },

    {
       delay = {time = 0.1,},
    },

    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(565,585),    order     = 41,
            file = "_lead_",    animation = "daiji",
            scale = 0.04,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.6, rotation3D=cc.vec3(0,180,0),
        },},


    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(700,615),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.03,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {remove = { model = {"zjue", },},},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(565,585),    order     = 41,
            file = "_lead_",    animation = "pose",
            scale = 0.04,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},


    {action = {tag  = "zjue",sync = false,what ={ spawn={{scale= {time = 0.8,to = 0.07,},},
    {bezier = {time = 0.5,to = cc.p(250,475),
                                 control={cc.p(565,585),cc.p(400,550),}
    },},},
    },},},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {remove = { model = {"ysjling", },},},
    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(700,615),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.03,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "ysjling",sync = false,what ={ spawn={{scale= {time = 0.8,to = 0.06,},},
    {bezier = {time = 0.5,to = cc.p(275,500),
                                 control={cc.p(700,615),cc.p(400,650),}
    },},},
    },},},

    {
       delay = {time = 0.3,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.1","0.85","200","-200"},},
     },

    {remove = { model = {"zjue", },},},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(250,475),    order     = 41,
            file = "_lead_",    animation = "daiji",
            scale = 0.07,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"ysjling", },},},
    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(275,500),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.06,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {remove = { model = {"zjue", },},},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(250,475),    order     = 41,
            file = "_lead_",    animation = "pose",
            scale = 0.06,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,0),
        },},


    {action = {tag  = "zjue",sync = false,what ={ spawn={{scale= {time = 1,to = 0.13,},},
    {bezier = {time = 0.3,to = cc.p(-175,150),
                                 control={cc.p(250,475),cc.p(-50,500),}
    },},},
    },},},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {remove = { model = {"ysjling", },},},
    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(275,500),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.07,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "ysjling",sync = false,what ={ spawn={{scale= {time = 1,to = 0.13,},},
    {bezier = {time = 0.3,to = cc.p(0,200),
                                 control={cc.p(275,500),cc.p(100,450),}
    },},},
    },},},

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"zjue", },},},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-175,150),    order     = 41,
            file = "_lead_",    animation = "daiji",
            scale = 0.13,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {remove = { model = {"ysjling", },},},
    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(0,200),    order     = 40,
            file = "hero_yinsuojinling",    animation = "daiji",
            scale = 0.13,   parent = "clip_1",
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("住手！哈哈，看来还得我出马！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out2",
            params = {"zj",},},
    },

    {
       delay = {time = 0.1,},
    },

      {remove = { model = {"text-board", },},},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {action = {tag  = "zjue",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.145,},},
    {bezier = {time = 0.6,to = cc.p(-300,0),
                                 control={cc.p(-75,150),cc.p(-120,250),}
    },},},
    },},},

    {remove = { model = {"zjue", },},},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-300,0),    order     = 41,
            file = "_lead_",    animation = "pugong",
            scale = 0.145,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1.1, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {   model = {
            tag  = "zjue1",     type  = DEF.FIGURE,
            pos= cc.p(-300,0),    order     = 41,
            file = "_lead_",    animation = "pugong",
            scale = 0.145,   parent = "clip_1", opacity=155,
            loop = false,   endRlease = false,  speed=1.1, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "zjue1",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,-10),},},
    {bezier = {time = 0.7,to = cc.p(-300,0),
                                 control={cc.p(-75,150),cc.p(-120,250),}
    },},},
    },},},

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "hero_nanzhu_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "zjue2",     type  = DEF.FIGURE,
            pos= cc.p(-300,0),    order     = 41,
            file = "_lead_",    animation = "pugong",
            scale = 0.145,   parent = "clip_1", opacity=155,
            loop = false,   endRlease = false,  speed=1.1, rotation3D=cc.vec3(0,180,0),
        },},

    {action = {tag  = "zjue2",sync = false,what ={ spawn={{rotate= {time = 0,to  = cc.vec3(0,0,10),},},
    {bezier = {time = 0.7,to = cc.p(-300,0),
                                 control={cc.p(-75,150),cc.p(-120,250),}
    },},},
    },},},

    {
       delay = {time = 0.1,},
    },

     {action = {
             tag  = "zjue1",sync = false,what = {
             spawn = {{move = {time = 0.4,by= cc.p(0, 0), },},{fadeout = {time = 1.2,},},},
            },},},
    {
       delay = {time = 0.1,},
    },

     {action = {
             tag  = "zjue2",sync = false,what = {
             spawn = {{move = {time = 0.4,by= cc.p(0, 0), },},{fadeout = {time = 1.2,},},},
            },},},

    {
       delay = {time = 1.1,},
    },

    {remove = { model = {"oyke", },},},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-350,-100),    order     = 43,
            file = "hero_ouyangke",    animation = "aida",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = false,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-450,-100),},},},},


    {remove = { model = {"qqzhang", },},},
    {   model = {
            tag  = "qqzhang",     type  = DEF.FIGURE,
            pos= cc.p(-325,100),    order     = 41,
            file = "hero_qiuqianzhang",    animation = "aida",
            scale = 0.13,   parent = "clip_1", speed = 0.6,
            loop = false,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


        {action = { tag  = "qqzhang",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-425,100),},},},},


    {remove = { model = {"ykang", }, },},
    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-450,0),    order     = 42,
            file = "hero_yangkang",    animation = "aida",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = false,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "ykang",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-550,0),},},},},

    {
       delay = {time = 0.2,},
    },


    {remove = { model = {"oyke", },},},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-450,-100),    order     = 43,
            file = "hero_ouyangke",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {remove = { model = {"qqzhang", },},},
    {   model = {
            tag  = "qqzhang",     type  = DEF.FIGURE,
            pos= cc.p(-425,100),    order     = 41,
            file = "hero_qiuqianzhang",    animation = "yun",
            scale = 0.13,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},


    {remove = { model = {"ykang", }, },},
    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-550,0),    order     = 42,
            file = "hero_yangkang",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"zjue", },},},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-300,0),    order     = 41,
            file = "_lead_",    animation = "daiji",
            scale = 0.145,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"ysjl","jls.png",TR("粉衣少女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"ysjl",TR("笨蛋，别玩了！立即杀了欧阳克这群本该死之人，否则时空将会大乱！"),"1183.mp3"},},
     },

     {
         load = {tmpl = "move1",
             params = {"qqc","qqc.png",TR("神秘老妪")},},
     },

     {
         load = {tmpl = "talk",
             params = {"qqc",TR("哈，哈，哈，真以为你们能改变一切吗？"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"qqc","ysjl"},},
    },

    {
       delay = {time = 0.1,},
    },

      {remove = { model = {"text-board", },},},

    {
       delay = {time = 0.1,},
    },

    {   model = {
            tag  = "qqchi",     type  = DEF.FIGURE,
            pos= cc.p(-1000,0),    order     = 42,
            file = "hero_qiuqianchi",    animation = "zou",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "qqchi",sync = false,what = {move = {
                   time = 3,to = cc.p(-750,0),},},},},

    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.95","900","-200"},},
     },

    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","1.9","0.85","155","-200"},},
     },

    {
       delay = {time = 1.9,},
    },

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },

    {remove = { model = {"qqchi", },},},
    {   model = {
            tag  = "qqchi",     type  = DEF.FIGURE,
            pos= cc.p(-750,0),    order     = 42,
            file = "hero_qiuqianchi",    animation = "pose",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {action = {tag  = "qqchi",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.14,},},
    {bezier = {time = 0.5,to = cc.p(-200,400),
                                 control={cc.p(-750,0),cc.p(-300,300),}
    },},},
    },},},

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.5","0.9","190","-300"},},
     },

    {
       delay = {time = 0.1,},
    },

    {remove = { model = {"qqchi", },},},
    {   model = {
            tag  = "qqchi",     type  = DEF.FIGURE,
            pos= cc.p(-225,400),    order     = 42,
            file = "hero_qiuqianchi",    animation = "daiji",
            scale = 0.14,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

    {
       delay = {time = 0.1,},
    },

    {
        model = {
            tag       = "guangxiao",     type      = DEF.FIGURE,
            pos= cc.p(-225,500),     order     = 40,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 1,        loop      = true,opacity=150,
            endRlease = false,         parent = "clip_1", speed=0.8,rotation3D=cc.vec3(0,0,0),
        },},
    {
        model = {
            tag       = "guangxiao2",     type      = DEF.FIGURE,
            pos= cc.p(-225,500),     order     = 41,
            file      = "effect_ziweiruanjian",         animation = "animation",
            scale     = 1,        loop      = true,opacity=250,
            endRlease = false,         parent = "clip_1", speed=1.2,rotation3D=cc.vec3(0,180,0),
        },},

    {
        model = {
            tag       = "chuansong",     type      = DEF.FIGURE,
            pos= cc.p(-225,500),     order     = 35,
            file      = "effect_ui_chuansongmen",         animation = "chuansongmen",
            scaleX     = 0.8,   scaleY     = 0.8,       loop      = true,
            endRlease = false,         parent = "clip_1", speed=0.3,
        },},

     {
         load = {tmpl = "mod3111",
             params = {"effect_ui_shenbingqjinjie","0.25","0","200","clip_1"},},
     },

    {delay={time=0.15},},

    {
        model = {
            tag       = "xiangzi",     type      = DEF.FIGURE,
            pos= cc.p(-225,570),     order     = 101,
            file      = "effect_jinlun",         animation = "animation",
            scale     = 0.1,         loop      = true,
            endRlease = false,         parent = "clip_1", speed=2,
        },},

    {
        model = { tag = "yupan",type  = DEF.PIC,
                  file  = "yp.png",order = 100,scale=0.1,
                  pos   = cc.p(-225, 570),parent = "clip_1",rotation3D=cc.vec3(30,30,0),},
    },

    {
       delay = {time = 0.3,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.3","1.3","275","-450"},},
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
             params = {"qqc","qqc.png",TR("神秘老妪")},},
     },

     {
         load = {tmpl = "talk",
             params = {"qqc",TR("哈，哈，哈，洛白衣是我的，青灵玉盘也是我的！你们全部去死吧！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out1",
            params = {"qqc",},},
    },

    {
       delay = {time = 0.1,},
    },

      {remove = { model = {"text-board", },},},

    {
       delay = {time = 0.1,},
    },

     {
        model = {
            tag   = "mapbj1",
            type  = DEF.PIC,
            scale = 1.2,
            pos   = cc.p(320, 600),
            order = 80,
            file  = "bj.png",
        },
    },

    {   model = {
            tag  = "heimu",     type  = DEF.FIGURE,
            pos= cc.p(320,560),    order     = 81,
            file = "effect_nujifenwei",    animation = "animation",
            scale = 0.96,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,0,0),
        },},


     {
        model = {
            tag   = "qqc1",
            type  = DEF.PIC,
            scale = 0.05,
            pos   = cc.p(300, 700),
            order = 82,
            file  = "qqc.png",rotation3D=cc.vec3(0,0,0),
        },
    },

    {action = {tag  = "qqc1",sync = false,what ={ spawn={{scale= {time = 0.6,to = 0.4,},},
    {bezier = {time = 0.6,to = cc.p(280,640),
                                 control={cc.p(300,700),cc.p(290,300),}
    },},},
    },},},

    {
       delay = {time = 0.5,},
    },


    {   model = {
            tag  = "gongji",     type  = DEF.FIGURE,
            pos= cc.p(280,540),    order     = 83,
            file = "effect_ui_chuchang",    animation = "animation",
            scale = 0.2,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,25,-90),
        },},

    {action = {tag  = "gongji",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.8,},},
    {bezier = {time = 0.5,to = cc.p(280,100),
                                 control={cc.p(300,700),cc.p(280,300),}
    },},},
    },},},

    {
       delay = {time = 0.3,},
    },


    {remove = { model = {"qqc1", "gongji","heimu","mapbj1",}, },},


    {
       delay = {time = 0.1,},
    },

     {
         load = {tmpl = "jtttb",
             params = {"clip_1","0.6","0.8","200","-200"},},
     },

    {
       delay = {time = 0.1,},
    },

    {
        sound = {file = "hero_qiuqianchi_pugong.mp3",sync=false,},
    },

    {   model = {
            tag  = "gongji",     type  = DEF.FIGURE,
            pos= cc.p(300,500),    order     = 45,
            file = "effect_ui_chuchang",    animation = "animation",
            scale = 0.2,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,15,-90),
        },},

    {action = {tag  = "gongji",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.7,},},
    {bezier = {time = 1,to = cc.p(300,-200),
                                 control={cc.p(290,500),cc.p(295,400),}
    },},},
    },},},

    {
       delay = {time = 0.1,},
    },

    {   model = {
            tag  = "gongji",     type  = DEF.FIGURE,
            pos= cc.p(300,500),    order     = 45,
            file = "effect_ui_chuchang",    animation = "animation",
            scale = 0.2,
            loop = true,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,25,-45),
        },},

    {action = {tag  = "gongji",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.7,},},
    {bezier = {time = 1,to = cc.p(-100,-200),
                                 control={cc.p(300,500),cc.p(100,400),}
    },},},
    },},},

    {
       delay = {time = 0.1,},
    },


    {
        load = {
            tmpl = "shake",
        },
    },

    {
       delay = {time = 0.1,},
    },

    {
        load = {
            tmpl = "shake",
        },
    },

    {
       delay = {time = 0.1,},
    },

        {
        load = {
            tmpl = "shake",
        },
    },

    {
       delay = {time = 0.1,},
    },

        {
        load = {
            tmpl = "shake",
        },
    },

    {remove = { model = {"oyke", },},},
    {   model = {
            tag  = "oyke",     type  = DEF.FIGURE,
            pos= cc.p(-450,-100),    order     = 43,
            file = "hero_ouyangke",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "oyke",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-500,-100),},},},},

    {remove = { model = {"qqzhang", },},},
    {   model = {
            tag  = "qqzhang",     type  = DEF.FIGURE,
            pos= cc.p(-425,100),    order     = 41,
            file = "hero_qiuqianzhang",    animation = "yun",
            scale = 0.13,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "qqzhang",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-475,100),},},},},

    {remove = { model = {"ykang", }, },},
    {   model = {
            tag  = "ykang",     type  = DEF.FIGURE,
            pos= cc.p(-550,0),    order     = 42,
            file = "hero_yangkang",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,0,0),
        },},

        {action = { tag  = "ykang",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-600,0),},},},},

    {remove = { model = {"zjue", },},},
    {   model = {
            tag  = "zjue",     type  = DEF.FIGURE,
            pos= cc.p(-300,0),    order     = 41,
            file = "_lead_",    animation = "aida",
            scale = 0.145,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "zjue",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-250,0),},},},},

    {remove = { model = {"ysjling", },},},
    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(0,200),    order     = 40,
            file = "hero_yinsuojinling",    animation = "aida",
            scale = 0.13,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=1, rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "ysjling",sync = false,what = {move = {
                   time = 0.1,to = cc.p(50,200),},},},},

    {remove = { model = {"gjing", }, },},
    {   model = {
            tag  = "gjing",     type  = DEF.FIGURE,
            pos= cc.p(-100,0),    order     = 42,
            file = "hero_guojing",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "gjing",sync = false,what = {move = {
                   time = 0.1,to = cc.p(-50,0),},},},},

    {remove = { model = {"hrong", }, },},
    {   model = {
            tag  = "hrong",     type  = DEF.FIGURE,
            pos= cc.p(50,0),    order     = 42,
            file = "hero_huangrong",    animation = "yun",
            scale = 0.15,   parent = "clip_1", speed = 0.6,
            loop = true,   endRlease = false,   rotation3D=cc.vec3(0,180,0),
        },},

        {action = { tag  = "hrong",sync = false,what = {move = {
                   time = 0.1,to = cc.p(100,0),},},},},

    {
       delay = {time = 0.2,},
    },


    {
        model = { tag = "text-board",type  = DEF.PIC,
                  file  = "jq_28.png",order = 51,
                  pos   = cc.p(DEF.WIDTH / 2, 280),fadein = { time = 1,},},
    },

     {
         load = {tmpl = "move2",
             params = {"ysjl","jls.png",TR("粉衣少女")},},
     },

     {
         load = {tmpl = "talk",
             params = {"ysjl",TR("快走！"),"1183.mp3"},},
     },

     {
         load = {tmpl = "move1",
             params = {"zj","_body_","@main"},},
     },

     {
         load = {tmpl = "talk",
             params = {"zj",TR("不要啊！"),"1183.mp3"},},
     },

    {
        load = {tmpl = "out3",
            params = {"zj","ysjl"},},
    },

    {
       delay = {time = 0.1,},
    },

      {remove = { model = {"text-board", },},},

    {
        sound = {file = "challenge_flag.mp3",sync=false,},
    },


    {remove = { model = {"ysjling", },},},
    {   model = {
            tag  = "ysjling",     type  = DEF.FIGURE,
            pos= cc.p(0,200),    order     = 46,
            file = "hero_yinsuojinling",    animation = "pugong",
            scale = 0.13,   parent = "clip_1",
            loop = false,   endRlease = false,  speed=0.8, rotation3D=cc.vec3(0,180,20),
        },},

    {action = {tag  = "ysjling",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.12,},},
    {bezier = {time = 0.2,to = cc.p(-150,250),
                                 control={cc.p(0,200),cc.p(-100,250),}
    },},},
    },},},

    {remove = { model = {"qqchi", },},},
    {   model = {
            tag  = "qqchi",     type  = DEF.FIGURE,
            pos= cc.p(-225,400),    order     = 45,
            file = "hero_qiuqianchi",    animation = "pugong",
            scale = 0.14,   parent = "clip_1", speed = 0.8,
            loop = false,   endRlease = false,   rotation3D=cc.vec3(0,0,-20),
        },},

    {action = {tag  = "qqchi",sync = false,what ={ spawn={{scale= {time = 0.2,to = 0.14,},},
    {bezier = {time = 0.2,to = cc.p(-200,400),
                                 control={cc.p(-225,400),cc.p(-215,365),}
    },},},
    },},},

    {
       delay = {time = 1,},
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