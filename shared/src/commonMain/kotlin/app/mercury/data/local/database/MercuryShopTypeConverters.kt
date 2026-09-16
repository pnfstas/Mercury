//
//  MercuryShopTypeConverters.kt
//  iosApp
//
//  Created by Panferov Stanislav on 03.08.2026.
//
package app.mercury.data.local.database

import androidx.room.TypeConverter
import app.mercury.data.local.entities.ContactType
import app.mercury.data.local.entities.OrderStatus
import kotlinx.datetime.LocalDateTime
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.datetime.toLocalDateTime
import kotlinx.serialization.json.Json
import kotlin.time.Instant

class MercuryShopTypeConverters {
    @TypeConverter
    fun fromContactTypeToStringMap(value: Map<ContactType, String>) : String {
        return Json.encodeToString(value)
    }
    @TypeConverter
    fun toContactTypeToStringMap(value: String) : Map<ContactType, String> {
        return Json.decodeFromString(value)
    }
    @TypeConverter
    fun fomLocalDateTime(value: LocalDateTime) : Long {
        return value.toInstant(TimeZone.currentSystemDefault()).toEpochMilliseconds()
    }
    @TypeConverter
    fun toLocalDateTime(value: Long) : LocalDateTime {
        return Instant.fromEpochMilliseconds(value).toLocalDateTime(TimeZone.currentSystemDefault())
    }
    @TypeConverter
    fun fromOrderStatus(value: OrderStatus) : Int {
        return value.ordinal
    }
    @TypeConverter
    fun toOrderStatus(value: Int) : OrderStatus {
        return OrderStatus.entries.firstOrNull { it.ordinal == value } ?: OrderStatus.None
    }
}