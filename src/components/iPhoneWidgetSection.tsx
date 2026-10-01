import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Alert,
  Platform,
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { updateZeniusWidget, ZeniusWidgetData } from '../native/WidgetModule';

export default function IPhoneWidgetSection() {
  const [streakDays, setStreakDays] = useState<number>(15);
  const [progressPercent, setProgressPercent] = useState<number>(85);
  const [currentSubject, setCurrentSubject] = useState<string>(
    'Matematika - Kalkulus'
  );
  const [nextClassTime, setNextClassTime] = useState<string>('16:00 WIB');
  const [activeTab, setActiveTab] = useState<'Small' | 'Medium' | 'Large'>(
    'Medium'
  );

  const handleSyncToWidget = async () => {
    const data: ZeniusWidgetData = {
      streakDays,
      currentSubject,
      progressPercent,
      nextClassTime,
      quote: 'Pahami Konsep, Kuasai Nalar.',
    };

    const success = await updateZeniusWidget(data);
    if (success) {
      Alert.alert(
        'Widget iOS Diperbarui',
        'Data widget iPhone milikmu telah berhasil diperbarui ke WidgetKit!'
      );
    } else {
      Alert.alert(
        'Pratinjau Widget',
        'Data disimulasikan! (Fitur WidgetKit iOS aktif di perangkat iPhone asli/simulator).'
      );
    }
  };

  return (
    <View style={styles.cardContainer}>
      {/* Header */}
      <View style={styles.headerRow}>
        <View style={styles.titleGroup}>
          <Ionicons name="phone-portrait-outline" size={22} color="#4F46E5" />
          <Text style={styles.headerTitle}>iPhone Home Screen Widget</Text>
        </View>
        <View style={styles.badgePill}>
          <Text style={styles.badgeText}>WidgetKit iOS</Text>
        </View>
      </View>

      <Text style={styles.description}>
        Widget iOS resmi Zenius untuk melihat streak harian, modul selanjutnya, dan
        akses cepat langsung dari Layar Utama iPhone.
      </Text>

      {/* Widget Size Tabs */}
      <View style={styles.sizeTabRow}>
        {(['Small', 'Medium', 'Large'] as const).map((size) => (
          <TouchableOpacity
            key={size}
            activeOpacity={0.8}
            style={[
              styles.sizeTab,
              activeTab === size && styles.activeSizeTab,
            ]}
            onPress={() => setActiveTab(size)}
          >
            <Text
              style={[
                styles.sizeTabText,
                activeTab === size && styles.activeSizeTabText,
              ]}
            >
              Ukuran {size}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Live Preview Container */}
      <View style={styles.previewContainer}>
        {activeTab === 'Small' && (
          <View style={styles.smallWidgetPreview}>
            <View style={styles.previewHeader}>
              <Text style={styles.logoText}>ZENIUS</Text>
              <Ionicons name="flame" size={16} color="#EA580C" />
            </View>
            <Text style={styles.streakNumber}>{streakDays} Hari</Text>
            <Text style={styles.streakSub}>Streak Belajar 🔥</Text>
            <Text style={styles.subjectText} numberOfLines={1}>
              {currentSubject}
            </Text>
          </View>
        )}

        {activeTab === 'Medium' && (
          <View style={styles.mediumWidgetPreview}>
            <View style={styles.mediumLeftColumn}>
              <Text style={styles.subTag}>ZENIUS • TARGET HARI INI</Text>
              <Text style={styles.streakNumber}>{streakDays} Hari 🔥</Text>
              <Text style={styles.progressText}>
                Target: {progressPercent}% Selesai
              </Text>
              {/* Progress bar */}
              <View style={styles.progressBarTrack}>
                <View
                  style={[
                    styles.progressBarFill,
                    { width: `${progressPercent}%` },
                  ]}
                />
              </View>
            </View>

            <View style={styles.divider} />

            <View style={styles.mediumRightColumn}>
              <Text style={styles.subTag}>KELAS SELANJUTNYA</Text>
              <Text style={styles.nextSubjectText} numberOfLines={2}>
                {currentSubject}
              </Text>
              <Text style={styles.timeText}>🕒 {nextClassTime}</Text>

              <TouchableOpacity style={styles.continueBtn} activeOpacity={0.8}>
                <Text style={styles.continueBtnText}>Lanjutkan ➔</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}

        {activeTab === 'Large' && (
          <View style={styles.largeWidgetPreview}>
            <View style={styles.largeHeader}>
              <View>
                <Text style={styles.logoText}>ZENIUS EDUCATION</Text>
                <Text style={styles.largeTitle}>Dashboard Belajar Nalar</Text>
              </View>
              <Ionicons name="flame" size={26} color="#EA580C" />
            </View>

            <View style={styles.largeBanner}>
              <View>
                <Text style={styles.bannerLabel}>Streak Belajar</Text>
                <Text style={styles.bannerVal}>{streakDays} Hari Berturut</Text>
              </View>
              <View>
                <Text style={styles.bannerLabel}>Progress</Text>
                <Text style={styles.bannerVal}>{progressPercent}% Selesai</Text>
              </View>
            </View>

            <Text style={styles.subTag}>AKSES CEPAT MATERI</Text>
            <View style={styles.quickLaunchRow}>
              <View style={[styles.quickBox, { backgroundColor: '#EEF2FF' }]}>
                <Text style={{ color: '#4F46E5', fontWeight: '700', fontSize: 11 }}>
                  📐 Matematika
                </Text>
              </View>
              <View style={[styles.quickBox, { backgroundColor: '#E0F2FE' }]}>
                <Text style={{ color: '#0284C7', fontWeight: '700', fontSize: 11 }}>
                  ⚛️ Fisika
                </Text>
              </View>
              <View style={[styles.quickBox, { backgroundColor: '#FEF3C7' }]}>
                <Text style={{ color: '#D97706', fontWeight: '700', fontSize: 11 }}>
                  🎯 UTBK 2026
                </Text>
              </View>
            </View>
          </View>
        )}
      </View>

      {/* Controls & Sync Button */}
      <View style={styles.controlsRow}>
        <TouchableOpacity
          style={styles.adjustBtn}
          activeOpacity={0.7}
          onPress={() => {
            setStreakDays((prev) => prev + 1);
            setProgressPercent((prev) => Math.min(prev + 5, 100));
          }}
        >
          <Ionicons name="add-circle-outline" size={18} color="#4F46E5" />
          <Text style={styles.adjustBtnText}>Tambah Progress</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={styles.syncBtn}
          activeOpacity={0.8}
          onPress={handleSyncToWidget}
        >
          <Ionicons name="sync-outline" size={18} color="#FFFFFF" />
          <Text style={styles.syncBtnText}>Simpan ke Widget iOS</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  cardContainer: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    padding: 16,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    marginVertical: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.03,
    shadowRadius: 12,
    elevation: 3,
  },
  headerRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  titleGroup: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 8,
  },
  headerTitle: {
    fontSize: 16,
    fontWeight: '800',
    color: '#0F172A',
  },
  badgePill: {
    backgroundColor: '#EEF2FF',
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 12,
  },
  badgeText: {
    fontSize: 11,
    fontWeight: '700',
    color: '#4F46E5',
  },
  description: {
    fontSize: 13,
    color: '#64748B',
    lineHeight: 18,
    marginBottom: 14,
  },
  sizeTabRow: {
    flexDirection: 'row',
    backgroundColor: '#F1F5F9',
    borderRadius: 12,
    padding: 4,
    marginBottom: 14,
  },
  sizeTab: {
    flex: 1,
    paddingVertical: 8,
    alignItems: 'center',
    borderRadius: 8,
  },
  activeSizeTab: {
    backgroundColor: '#FFFFFF',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 1,
  },
  sizeTabText: {
    fontSize: 12,
    fontWeight: '600',
    color: '#64748B',
  },
  activeSizeTabText: {
    color: '#4F46E5',
    fontWeight: '700',
  },

  // Live Preview Styling
  previewContainer: {
    backgroundColor: '#F8FAFC',
    borderRadius: 16,
    padding: 14,
    borderWidth: 1.5,
    borderColor: '#CBD5E1',
    borderStyle: 'dashed',
    marginBottom: 14,
    alignItems: 'center',
  },
  smallWidgetPreview: {
    width: 140,
    height: 140,
    backgroundColor: '#FFFFFF',
    borderRadius: 18,
    padding: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 6,
    elevation: 3,
    justifyContent: 'space-between',
  },
  previewHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  logoText: {
    fontSize: 11,
    fontWeight: '800',
    color: '#4F46E5',
    letterSpacing: 0.5,
  },
  streakNumber: {
    fontSize: 22,
    fontWeight: '900',
    color: '#0F172A',
  },
  streakSub: {
    fontSize: 11,
    fontWeight: '600',
    color: '#EA580C',
  },
  subjectText: {
    fontSize: 11,
    fontWeight: '600',
    color: '#4F46E5',
  },

  mediumWidgetPreview: {
    width: '100%',
    height: 120,
    backgroundColor: '#FFFFFF',
    borderRadius: 18,
    padding: 14,
    flexDirection: 'row',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 6,
    elevation: 3,
    gap: 12,
  },
  mediumLeftColumn: {
    flex: 1,
    gap: 4,
  },
  subTag: {
    fontSize: 9,
    fontWeight: '800',
    color: '#94A3B8',
    letterSpacing: 0.5,
    marginBottom: 2,
  },
  progressText: {
    fontSize: 11,
    color: '#64748B',
  },
  progressBarTrack: {
    height: 6,
    backgroundColor: '#E2E8F0',
    borderRadius: 3,
    marginTop: 4,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: '#4F46E5',
    borderRadius: 3,
  },
  divider: {
    width: 1,
    height: '80%',
    backgroundColor: '#E2E8F0',
  },
  mediumRightColumn: {
    width: 115,
    gap: 4,
  },
  nextSubjectText: {
    fontSize: 12,
    fontWeight: '700',
    color: '#0F172A',
  },
  timeText: {
    fontSize: 11,
    color: '#64748B',
  },
  continueBtn: {
    backgroundColor: '#4F46E5',
    borderRadius: 8,
    paddingVertical: 5,
    paddingHorizontal: 8,
    alignItems: 'center',
    marginTop: 4,
  },
  continueBtnText: {
    color: '#FFFFFF',
    fontSize: 10.5,
    fontWeight: '700',
  },

  largeWidgetPreview: {
    width: '100%',
    backgroundColor: '#FFFFFF',
    borderRadius: 18,
    padding: 14,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.08,
    shadowRadius: 6,
    elevation: 3,
    gap: 10,
  },
  largeHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  largeTitle: {
    fontSize: 15,
    fontWeight: '800',
    color: '#0F172A',
  },
  largeBanner: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    backgroundColor: '#4F46E5',
    padding: 12,
    borderRadius: 12,
  },
  bannerLabel: {
    fontSize: 10,
    color: 'rgba(255, 255, 255, 0.8)',
  },
  bannerVal: {
    fontSize: 15,
    fontWeight: '800',
    color: '#FFFFFF',
  },
  quickLaunchRow: {
    flexDirection: 'row',
    gap: 6,
  },
  quickBox: {
    flex: 1,
    paddingVertical: 8,
    alignItems: 'center',
    borderRadius: 8,
  },

  controlsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    gap: 8,
  },
  adjustBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingVertical: 10,
    paddingHorizontal: 12,
    backgroundColor: '#EEF2FF',
    borderRadius: 12,
  },
  adjustBtnText: {
    fontSize: 12.5,
    fontWeight: '700',
    color: '#4F46E5',
  },
  syncBtn: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 6,
    paddingVertical: 10,
    paddingHorizontal: 16,
    backgroundColor: '#4F46E5',
    borderRadius: 12,
  },
  syncBtnText: {
    fontSize: 12.5,
    fontWeight: '700',
    color: '#FFFFFF',
  },
});
