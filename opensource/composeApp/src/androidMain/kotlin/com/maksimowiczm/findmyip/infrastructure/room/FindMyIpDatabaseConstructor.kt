package com.maksimowiczm.findmyip.infrastructure.room

import androidx.room.RoomDatabaseConstructor

internal actual object FindMyIpDatabaseConstructor : RoomDatabaseConstructor<FindMyIpDatabase> {
    override fun initialize(): FindMyIpDatabase = throw NotImplementedError()
}
