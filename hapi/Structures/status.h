/*
 * Copyright (c) Novedia Group 2012.
 *
 *     This file is part of Hubiquitus.
 *
 *     Hubiquitus is free software: you can redistribute it and/or modify
 *     it under the terms of the GNU General Public License as published by
 *     the Free Software Foundation, either version 3 of the License, or
 *     (at your option) any later version.
 *
 *     Hubiquitus is distributed in the hope that it will be useful,
 *     but WITHOUT ANY WARRANTY; without even the implied warranty of
 *     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *     GNU General Public License for more details.
 *
 *     You should have received a copy of the GNU General Public License
 *     along with Hubiquitus.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @version 0.5.0
 * Connection status. See HStatus.status
 */

typedef enum {
    CONNECTING = 1,
    CONNECTED = 2,
    DISCONNECTING = 5, 
    DISCONNECTED = 6
} Status;

typedef enum {
    RES_OK = 0,
    RES_TECH_ERROR = 1,
    RES_NOT_CONNECTED = 3,
    RES_NOT_AUTHORIZED = 5,
    RES_MISSING_ATTR = 6,
    RES_INVALID_ATTR = 7,
    RES_NOT_AVAILABLE = 9,
    RES_EXEC_TIMEOUT = 10
} ResultStatus;
