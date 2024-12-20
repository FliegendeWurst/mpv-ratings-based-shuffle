utils = require 'mp.utils'
require 'mp.options'

local options = {
    directory = ".",
    ratings_file = "RBS-ratings.txt",
    exclude = "/dev/null",
}
read_options(options, "ratings-based-shuffle")

all_files = {}
ratings = {}
init = false

function init_playlist()
    mp.osd_message("Initializing ratings-based shuffle..")
    mp.set_property("shuffle", "no")
    mp.set_property("loop-playlist", "no")

    load_ratings(options.ratings_file)
    load(options.directory)

    mp.commandv('loadfile', all_files[math.random(#all_files)], 'replace')

    mp.register_event("end-file", auto_add_file)
    auto_add_file(nil)

    init = true
end

function load(path)
    for idx, name in ipairs(utils.readdir(path, "dirs")) do
        load(utils.join_path(path, name))
    end
    for idx, name in ipairs(utils.readdir(path, "files")) do
        table.insert(all_files, utils.join_path(path, name))
    end
end

function load_ratings(path)
    info = utils.file_info(path)
    if info == nil then
        -- nothing to read
    elseif info.is_file then
        file = io.open(path, "r")
        io.input(file)
        ratings, err = utils.parse_json(io.read())
        if not (err == nil) then
            msg.warn("could not load preferences")
            msg.warn(err)
        end
        io.close(file)
    else
        msg.warn("could not load ratings")
    end
end

function save_ratings(path)
    info = utils.file_info(path)
    if info == nil or info.is_file then
        file = io.open(path, "w")
        io.output(file)
        json, err = utils.format_json(ratings)
        io.write(json)
        io.close(file)
    else
        msg.error("could not save ratings")
    end
end

function upvote()
    if not init then
        return
    end
    file = mp.get_property("path")
    if ratings[file] == nil then
        ratings[file] = 1.1
    else
        ratings[file] = ratings[file] * 1.1
    end
    mp.osd_message("new rating: " .. ratings[file])
    save_ratings(options.ratings_file)
end

function downvote()
    if not init then
        return
    end
    file = mp.get_property("path")
    if ratings[file] == nil then
        ratings[file] = 0.9
    else
        ratings[file] = ratings[file] * 0.9
    end
    mp.osd_message("new rating: " .. ratings[file])
    save_ratings(options.ratings_file)
end

function auto_add_file(event)
    while true do
        ::select_file::

        idx = math.random(#all_files)
        file = all_files[idx]
        if not (options.exclude == nil) and file:find(options.exclude, 1, true) == 1 then
            goto select_file
        end
        chance = ratings[file]
        if chance == nil then
            chance = 1.0
        end
        if math.random() < (chance/#all_files) then
            mp.commandv('loadfile', file, 'append')
            break
        end
    end
end

math.randomseed(math.sin(os.time())*10000)
mp.register_script_message("RBS-init", init_playlist)
mp.register_script_message("RBS-upvote", upvote)
mp.register_script_message("RBS-downvote", downvote)
