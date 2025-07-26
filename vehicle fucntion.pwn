
 __      ____________ ________  ____  ___   _______________  ___
/  \    /  \______   \\_____  \ \   \/  /   \_   _____/\   \/  /
\   \/\/   /|       _/ /   |   \ \     /     |    ___  \     / 
 \        / |    |   \/    |    \/     \     |        \ /     \ 
  \__/\  /  |____|_  /\_______  /___/\  \   /_______  //___/\  \
       \/          \/         \/      \_/           \/       \_/



[-] DEVELOPED BY  - ** ZPYRX & WROXEXM **
[-] FULLY COUSTUM MADED CODE  BY WROXEXM  - 
[-] BASE IS OUT OF MY MIND !



- LETS GOOOOM 
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// A ADVNACED VEHICLE MIEAGE IMPLEMENT SYSTEM BY WROXEXM 
#define MAX_VEHICLES 2000

new Float:g_VehicleMileage[MAX_VEHICLES];
new Float:g_LastVehiclePos[MAX_VEHICLES][3];

stock LoadMileageFromDB(vehicleid)
{
    new query[128];
    format(query, sizeof(query), "SELECT mileage FROM vehicle_mileage WHERE vehicle_id = %d", vehicleid);
    mysql_tquery(ConnectionID, query, "OnMileageLoad", "i", vehicleid);
}

forward OnMileageLoad(vehicleid);
public OnMileageLoad(vehicleid)
{
    if (cache_num_rows() > 0)
    {
        cache_get_field_content(0, "mileage", g_VehicleMileage[vehicleid]);
    }
    else
    {
        g_VehicleMileage[vehicleid] = 0.0;
    }

    GetVehiclePos(vehicleid, g_LastVehiclePos[vehicleid][0], g_LastVehiclePos[vehicleid][1], g_LastVehiclePos[vehicleid][2]);
}


forward UpdateVehicleMileage();
public UpdateVehicleMileage()
{
    for (new i = 0; i < MAX_VEHICLES; i++)
    {
        if (!IsVehicleOccupied(i)) continue;

        new Float:x, Float:y, Float:z;
        GetVehiclePos(i, x, y, z);

        new Float:distance = floatsqroot(
            floatpower(x - g_LastVehiclePos[i][0], 2.0) +
            floatpower(y - g_LastVehiclePos[i][1], 2.0) +
            floatpower(z - g_LastVehiclePos[i][2], 2.0)
        );

        if (distance >= 0.9) // avoid micro movements
        {
            g_VehicleMileage[i] += distance;

            g_LastVehiclePos[i][0] = x;
            g_LastVehiclePos[i][1] = y;
            g_LastVehiclePos[i][2] = z;

            SaveMileageToDB(i);
        }
    }
    return 1;
}

stock SaveMileageToDB(vehicleid)
{
    new query[256];
    new ownerid = VehicleInfo[vehicleid][vOwnerID]; 

    format(query, sizeof(query),
        "INSERT INTO vehicle_mileage (vehicle_id, owner_id, mileage) VALUES (%d, %d, %.2f) \
        ON DUPLICATE KEY UPDATE mileage = %.2f",
        vehicleid, ownerid, g_VehicleMileage[vehicleid], g_VehicleMileage[vehicleid]);

    mysql_tquery(ConnectionID, query);
}

public OnGameModeInit()
{
    SetTimer("UpdateVehicleMileage", 1000, true);
    return 1;
}

CMD:vmileage(playerid, params[])
{
    new vehicleid = GetPlayerVehicleID(playerid);

    if (vehicleid == 0 || !IsValidVehicle(vehicleid))
    {
        return SendClientMessage(playerid, COLOR_RED, "ERROR: You are not in a valid vehicle.");
    }

    new ownerid = VehicleInfo[vehicleid][vOwnerID];
    new ownerName[MAX_PLAYER_NAME];

    if (IsPlayerConnected(ownerid))
    {
        GetPlayerName(ownerid, ownerName, sizeof(ownerName));
    }
    else
    {
        format(ownerName, sizeof(ownerName), "Unknown");
    }
   
    new Float:mileage = g_VehicleMileage[vehicleid];
    new formattedMileage[32];

    if (mileage < 1000.0)
    {
        format(formattedMileage, sizeof(formattedMileage), "%.0f meters", mileage);
    }      
    else
    {
        format(formattedMileage, sizeof(formattedMileage), "%.2f km", mileage / 1000.0);
    }

    new msg[128];
    format(msg, sizeof(msg),"{00FF00}[VEHICLE MILEAGE INFO]\n{FFFFFF}Vehicle ID: %d\nOwner: %s\nMileage: %s", vehicleid, ownerName, formattedMileage);
    SendClientMessage(playerid, COLOR_YELLOW, msg);
    return 1;
}
