#################################
# MAP AND MODEL                 #
#################################

param map = localPath('../maps/carla/Town03.xodr')
param carla_map = 'Town03'
model scenic.simulators.carla.model

#################################
# CONSTANTS                     #
#################################

param N = 5  # number of additional vehicles

MODEL = 'vehicle.lincoln.mkz2017'

param EGO_SPEED = VerifaiRange(7, 10)
param OTHER_SPEEDS = [VerifaiRange(7, 10) for _ in range(globalParameters.N)]

#################################
# SPATIAL RELATIONS             #
#################################

roundabout = Uniform(*filter(lambda i: len(i.incomingLanes) == 7, network.intersections))

egoInitLane = Uniform(*roundabout.incomingLanes)
egoManeuver = Uniform(*egoInitLane.maneuvers)
egoTrajectory = [egoInitLane, egoManeuver.connectingLane, egoManeuver.endLane]

#################################
# SCENARIO SPECIFICATION        #
#################################

ego = Car on egoInitLane,
	with blueprint MODEL,
	with behavior FollowTrajectoryBehavior(target_speed=globalParameters.EGO_SPEED, trajectory=egoTrajectory)

for i in range(globalParameters.N):
    tempInitLane = Uniform(*roundabout.incomingLanes)
    tempManeuver = Uniform(*tempInitLane.maneuvers)
    tempTrajectory = [tempInitLane, tempManeuver.connectingLane, tempManeuver.endLane]
    Car on tempInitLane,
        with behavior FollowTrajectoryBehavior(target_speed=globalParameters.OTHER_SPEEDS[i], trajectory=tempTrajectory)
