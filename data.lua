--data.lua

require("prototypes.item")

data:extend(
    {
        {
            attack_parameters = {
                type = "beam",
                range = 0,
                cooldown = 10,
                ammo_type = {category = "bullet"},
                animation = {
                    direction_count = 4,
                    width = 128,
                    height = 128,
                    stripes = { { width_in_frames = 2, height_in_frames = 2, filename = '__factorio-ai__/art/ai-spritesheet.png' } }
                }
            },
            type = "unit",
            name = "ai-pathfinder",
            flags = {"placeable-neutral", "placeable-off-grid", "not-on-map"},
            icon = "__factorio-ai__/art/ai-pathfinder.png",
            collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
            distance_per_frame = 10,
            pollution_to_join_attack = 10000000000000000000000000000000000000000000,
            distraction_cooldown = 4294967295,
            movement_speed = 0.5,
            vision_distance = 0,
            run_animation = {
                direction_count = 4,
                width = 128,
                height = 128,
                stripes = { { width_in_frames = 2, height_in_frames = 2, filename = '__factorio-ai__/art/ai-spritesheet.png' } }
            },
            order = "b[decorative]-b[asterisk]-a[brown]",
            selectable_in_game = false,
            icon_size = 25
        }
    }
)
