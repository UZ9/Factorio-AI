# Factorio-AI

An attempt at automating the automation game.

# Features
- Building structures relative to the player
- Inserting materials into structures
- Mining for x amount of resource
- Retrieving from entity inventories 
- Asynchronous operations 
- Pathfinding to point 
- Automatic recipe crafting

This project was inspired by submitteddenied's meta-factorio series, however because it stopped development over 2 years ago I decided to work on one of my own, with my own touch to it. One of the current noticeable differences is instead of using a "feeler" the mod will automatically calculate an optimal path using A* pathfinding. 

# Pathfinding to ore deposits 
![image](https://github.com/UZ9/Factorio-AI/assets/36551149/1bbe7f97-5dbb-4aa1-b710-4ff792d2b088)

# Ore Deposit Detection
![image](https://github.com/UZ9/Factorio-AI/assets/36551149/91ef9466-2878-46d0-a4a6-6a9572cc5d2d)

# Waypoint Tracker
![image](https://github.com/UZ9/Factorio-AI/assets/36551149/c3864846-2a2b-4176-b503-8dd01fdf0970)

# Objective Panel 
![image](https://github.com/UZ9/Factorio-AI/assets/36551149/c76a5dd8-390e-49b7-a189-a1d3e1cdd0ec)

# Current TODO
- [X] Use A* pathfinding to navigate around collisions and water tiles 
- [X] Find the closest of a specified ore type and pathfind to it 
- [X] Improve pathfinding movement (currently stuttering)
- [X] Place building at location task
- [ ] Hunt for wood task 
- [X] Mine at tile for x amount of resources task 
- [X] Document project better
