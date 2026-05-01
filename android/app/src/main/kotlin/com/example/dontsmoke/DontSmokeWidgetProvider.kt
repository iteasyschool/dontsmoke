package com.dontsmoke.kz

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.widget.RemoteViews
import kotlin.math.roundToLong

class DontSmokeWidgetProvider : AppWidgetProvider() {

    companion object {
        const val ACTION_PREV_SLIDE = "com.dontsmoke.kz.PREV_SLIDE"
        const val ACTION_NEXT_SLIDE = "com.dontsmoke.kz.NEXT_SLIDE"
        const val ACTION_NEXT_BG = "com.dontsmoke.kz.NEXT_BG"
        const val ACTION_REFRESH_TIME = "com.dontsmoke.kz.REFRESH_TIME"

        private const val REFRESH_REQUEST_CODE = 1001
        private const val REFRESH_INTERVAL_MILLIS = 60_000L

        const val FLUTTER_PREFS = "FlutterSharedPreferences"
        const val KEY_QUIT_DATE_MILLIS = "flutter.quit_date_millis"
        const val KEY_CIGARETTES_PER_DAY = "flutter.cigarettes_per_day"
        const val KEY_COST_PER_PACK = "flutter.cost_per_pack"
        const val KEY_CIGARETTES_PER_PACK = "flutter.cigarettes_per_pack"

        const val WIDGET_PREFS = "DontSmokeWidgetPrefs"
        const val KEY_SLIDE = "slide_index"
        const val KEY_BG = "bg_index"

        private val SLIDE_ICONS = arrayOf("\u23f1", "\ud83d\udcb0", "\ud83d\udead", "\u2764")
        private val SLIDE_LABELS = arrayOf(
            "\u0412\u0440\u0435\u043c\u044f \u0431\u0435\u0437 \u043a\u0443\u0440\u0435\u043d\u0438\u044f",
            "\u0421\u044d\u043a\u043e\u043d\u043e\u043c\u043b\u0435\u043d\u043e",
            "\u0421\u0438\u0433\u0430\u0440\u0435\u0442 \u043d\u0435 \u0432\u044b\u043a\u0443\u0440\u0435\u043d\u043e",
            "\u0416\u0438\u0437\u043d\u044c \u043f\u0440\u043e\u0434\u043b\u0435\u043d\u0430"
        )
        private val BG_ICONS = arrayOf("\u25d1", "\ud83c\udf19", "\u2600")

        private fun widgetIds(context: Context): IntArray {
            val manager = AppWidgetManager.getInstance(context)
            return manager.getAppWidgetIds(
                ComponentName(context, DontSmokeWidgetProvider::class.java)
            )
        }

        private fun refreshIntent(context: Context): Intent {
            return Intent(context, DontSmokeWidgetProvider::class.java).apply {
                action = ACTION_REFRESH_TIME
            }
        }

        private fun refreshPendingIntent(context: Context, flags: Int): PendingIntent? {
            return PendingIntent.getBroadcast(
                context,
                REFRESH_REQUEST_CODE,
                refreshIntent(context),
                flags or PendingIntent.FLAG_IMMUTABLE
            )
        }

        private fun readQuitMillis(context: Context): Long {
            val flutterPrefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
            return try { flutterPrefs.getLong(KEY_QUIT_DATE_MILLIS, -1L) } catch (e: Exception) { -1L }
        }

        private fun nextRefreshMillis(context: Context): Long {
            val now = System.currentTimeMillis()
            val quitMillis = readQuitMillis(context)

            if (quitMillis > 0 && now >= quitMillis) {
                val elapsed = now - quitMillis
                val remaining = REFRESH_INTERVAL_MILLIS - (elapsed % REFRESH_INTERVAL_MILLIS)
                return now + remaining + 250L
            }

            return now + REFRESH_INTERVAL_MILLIS
        }

        fun scheduleWidgetRefresh(context: Context) {
            if (widgetIds(context).isEmpty() || readQuitMillis(context) <= 0) {
                cancelWidgetRefresh(context)
                return
            }

            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val pendingIntent = refreshPendingIntent(context, PendingIntent.FLAG_UPDATE_CURRENT) ?: return

            alarmManager.setRepeating(
                AlarmManager.RTC,
                nextRefreshMillis(context),
                REFRESH_INTERVAL_MILLIS,
                pendingIntent
            )
        }

        fun cancelWidgetRefresh(context: Context) {
            val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val pendingIntent = refreshPendingIntent(context, PendingIntent.FLAG_NO_CREATE)
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent)
                pendingIntent.cancel()
            }
        }

        fun updateAllWidgets(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = widgetIds(context)
            for (id in ids) updateWidget(context, manager, id)
        }

        fun updateWidget(context: Context, manager: AppWidgetManager, widgetId: Int) {
            try {
                val flutterPrefs = context.getSharedPreferences(FLUTTER_PREFS, Context.MODE_PRIVATE)
                val widgetPrefs = context.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)

                val slideIndex = widgetPrefs.getInt(KEY_SLIDE, 0).coerceIn(0, 3)
                val bgIndex = widgetPrefs.getInt(KEY_BG, 0).coerceIn(0, 2)

                val quitMillis: Long = try { flutterPrefs.getLong(KEY_QUIT_DATE_MILLIS, -1L) } catch (e: Exception) { -1L }
                val cpd: Int = try { flutterPrefs.getLong(KEY_CIGARETTES_PER_DAY, 0L).toInt() } catch (e: Exception) { 0 }
                val cpp: Int = try { flutterPrefs.getLong(KEY_COST_PER_PACK, 0L).toInt() } catch (e: Exception) { 0 }
                val cpack: Int = try { flutterPrefs.getLong(KEY_CIGARETTES_PER_PACK, 20L).toInt().coerceAtLeast(1) } catch (e: Exception) { 20 }

                val views = RemoteViews(context.packageName, R.layout.dontsmoke_widget)

                val textColor: Int
                val subTextColor: Int
                val bgColor: Int
                when (bgIndex) {
                    0 -> { bgColor = Color.TRANSPARENT; textColor = Color.WHITE; subTextColor = Color.parseColor("#CCFFFFFF") }
                    1 -> { bgColor = Color.parseColor("#EE0D1117"); textColor = Color.WHITE; subTextColor = Color.parseColor("#BBFFFFFF") }
                    else -> { bgColor = Color.parseColor("#F0FFFFFF"); textColor = Color.parseColor("#1A1A2E"); subTextColor = Color.parseColor("#88000000") }
                }

                views.setInt(R.id.widget_bg, "setBackgroundColor", bgColor)
                views.setTextColor(R.id.widget_value, textColor)
                views.setTextColor(R.id.widget_label, subTextColor)
                val fgDim = if (bgIndex == 2) Color.parseColor("#88000000") else Color.parseColor("#88FFFFFF")
                val fgMid = if (bgIndex == 2) Color.parseColor("#CC000000") else Color.parseColor("#CCFFFFFF")
                val btnBg = if (bgIndex == 2) Color.parseColor("#22000000") else Color.parseColor("#33FFFFFF")
                views.setTextColor(R.id.widget_dots, fgDim)
                views.setTextColor(R.id.widget_bg_btn, fgMid)
                views.setInt(R.id.widget_bg_btn, "setBackgroundColor", btnBg)

                views.setTextViewText(R.id.widget_icon, SLIDE_ICONS[slideIndex])

                val (value, label) = calcStat(quitMillis, cpd, cpp, cpack, slideIndex)
                views.setTextViewText(R.id.widget_value, value)
                views.setTextViewText(R.id.widget_label, label)
                views.setTextViewText(R.id.widget_bg_btn, BG_ICONS[bgIndex])

                val dots = (0..3).joinToString(" ") { if (it == slideIndex) "\u25cf" else "\u25cb" }
                views.setTextViewText(R.id.widget_dots, dots)

                val prevSlideIntent = Intent(context, DontSmokeWidgetProvider::class.java).apply { action = ACTION_PREV_SLIDE }
                val prevSlidePi = PendingIntent.getBroadcast(context, 2, prevSlideIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                views.setOnClickPendingIntent(R.id.widget_prev_slide_area, prevSlidePi)

                val nextSlideIntent = Intent(context, DontSmokeWidgetProvider::class.java).apply { action = ACTION_NEXT_SLIDE }
                val nextSlidePi = PendingIntent.getBroadcast(context, 0, nextSlideIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                views.setOnClickPendingIntent(R.id.widget_next_slide_area, nextSlidePi)

                val nextBgIntent = Intent(context, DontSmokeWidgetProvider::class.java).apply { action = ACTION_NEXT_BG }
                val nextBgPi = PendingIntent.getBroadcast(context, 1, nextBgIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
                views.setOnClickPendingIntent(R.id.widget_bg_btn, nextBgPi)

                manager.updateAppWidget(widgetId, views)
            } catch (e: Exception) {
                // Silently skip on any error
            }
        }

        private fun calcStat(quitMillis: Long, cpd: Int, cpp: Int, cpack: Int, slideIndex: Int): Pair<String, String> {
            val label = SLIDE_LABELS[slideIndex]
            if (quitMillis < 0) return Pair("\u2014", label)
            val diffMs = System.currentTimeMillis() - quitMillis
            if (diffMs < 0) return Pair("\u2014", label)
            val minutes = diffMs / 60_000
            val hours = diffMs / 3_600_000
            val days = diffMs / 86_400_000
            val totalHours = diffMs / 3_600_000.0
            return when (slideIndex) {
                0 -> {
                    val value = when {
                        minutes < 60 -> "${minutes}\u043c"
                        hours < 24 -> "${hours}\u0447 ${minutes % 60}\u043c"
                        days < 30 -> "${days}\u0434 ${hours % 24}\u0447"
                        else -> "${days / 30}\u043c\u0435\u0441 ${days % 30}\u0434"
                    }
                    Pair(value, label)
                }
                1 -> {
                    val cigarettesSaved = totalHours * cpd.toDouble() / 24.0
                    val packsSaved = cigarettesSaved / cpack.toDouble()
                    val saved = (packsSaved * cpp.toDouble()).toLong()
                    Pair("$saved", label)
                }
                2 -> {
                    val avoided = (totalHours * cpd.toDouble() / 24.0).roundToLong()
                    Pair("$avoided", label)
                }
                else -> {
                    val addedMins = (totalHours * cpd.toDouble() * 11.0 / 24.0).toLong()
                    val value = when {
                        addedMins < 60 -> "${addedMins}\u043c"
                        addedMins < 1440 -> "${addedMins / 60}\u0447"
                        else -> "${addedMins / 1440}\u0434"
                    }
                    Pair(value, label)
                }
            }
        }
    }

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (id in appWidgetIds) updateWidget(context, appWidgetManager, id)
        scheduleWidgetRefresh(context)
    }

    override fun onEnabled(context: Context) {
        updateAllWidgets(context)
        scheduleWidgetRefresh(context)
    }

    override fun onDisabled(context: Context) {
        cancelWidgetRefresh(context)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val widgetPrefs = context.getSharedPreferences(WIDGET_PREFS, Context.MODE_PRIVATE)
        when (intent.action) {
            ACTION_REFRESH_TIME -> {
                updateAllWidgets(context)
            }
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> {
                updateAllWidgets(context)
                scheduleWidgetRefresh(context)
            }
            ACTION_PREV_SLIDE -> {
                val cur = widgetPrefs.getInt(KEY_SLIDE, 0)
                widgetPrefs.edit().putInt(KEY_SLIDE, (cur + 3) % 4).apply()
                updateAllWidgets(context)
            }
            ACTION_NEXT_SLIDE -> {
                val cur = widgetPrefs.getInt(KEY_SLIDE, 0)
                widgetPrefs.edit().putInt(KEY_SLIDE, (cur + 1) % 4).apply()
                updateAllWidgets(context)
            }
            ACTION_NEXT_BG -> {
                val cur = widgetPrefs.getInt(KEY_BG, 0)
                widgetPrefs.edit().putInt(KEY_BG, (cur + 1) % 3).apply()
                updateAllWidgets(context)
            }
        }
    }
}
