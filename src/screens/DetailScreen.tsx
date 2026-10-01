import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Alert,
} from 'react-native';
import { NativeStackScreenProps } from '@react-navigation/native-stack';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { RootStackParamList } from '../types/navigation';

type Props = NativeStackScreenProps<RootStackParamList, 'Detail'>;

export default function DetailScreen({ route, navigation }: Props) {
  const { title, category, level, description, lessonsCount, iconName, color } =
    route.params;

  const LESSON_CHAPTERS = [
    { id: 'l1', title: 'Bab 1: Pengenalan Konsep Nalar', duration: '12:45 min', isFree: true },
    { id: 'l2', title: 'Bab 2: Pemahaman Teori & Aplikasi', duration: '18:20 min', isFree: true },
    { id: 'l3', title: 'Bab 3: Latihan Soal Standar UTBK', duration: '24:15 min', isFree: false },
    { id: 'l4', title: 'Bab 4: Pembahasan Trik Cepat', duration: '15:10 min', isFree: false },
    { id: 'l5', title: 'Bab 5: Tryout & Evaluasi Mandiri', duration: '30:00 min', isFree: false },
  ];

  return (
    <View style={styles.container}>
      {/* Top Bar Navigation */}
      <View style={styles.topBar}>
        <TouchableOpacity
          activeOpacity={0.7}
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <Ionicons name="arrow-back" size={24} color="#0F172A" />
        </TouchableOpacity>
        <Text style={styles.topBarTitle}>Detail Modul</Text>
        <TouchableOpacity activeOpacity={0.7} style={styles.shareBtn}>
          <Ionicons name="share-social-outline" size={20} color="#0F172A" />
        </TouchableOpacity>
      </View>

      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Banner Box */}
        <View style={[styles.bannerBox, { backgroundColor: color }]}>
          <View style={styles.iconCircle}>
            <Ionicons name={iconName} size={40} color={color} />
          </View>
          <Text style={styles.bannerCategory}>{category}</Text>
          <Text style={styles.bannerTitle}>{title}</Text>
          <Text style={styles.bannerMeta}>
            {level} • {lessonsCount} Video Modul
          </Text>
        </View>

        {/* Description Card */}
        <View style={styles.infoCard}>
          <Text style={styles.sectionHeaderTitle}>Tentang Modul Ini</Text>
          <Text style={styles.descriptionText}>{description}</Text>
        </View>

        {/* Lessons List */}
        <View style={styles.lessonsContainer}>
          <Text style={styles.sectionHeaderTitle}>Daftar Bab & Video</Text>

          {LESSON_CHAPTERS.map((lesson, idx) => (
            <TouchableOpacity
              key={lesson.id}
              style={styles.lessonItem}
              activeOpacity={0.8}
              onPress={() =>
                Alert.alert('Mulai Pembelajaran', `Memutar ${lesson.title}`)
              }
            >
              <View style={styles.lessonNumBox}>
                <Text style={styles.lessonNumText}>{idx + 1}</Text>
              </View>

              <View style={styles.lessonInfo}>
                <Text style={styles.lessonTitle}>{lesson.title}</Text>
                <Text style={styles.lessonDuration}>{lesson.duration}</Text>
              </View>

              <Ionicons
                name={lesson.isFree ? 'play-circle' : 'lock-closed'}
                size={24}
                color={lesson.isFree ? color : '#94A3B8'}
              />
            </TouchableOpacity>
          ))}
        </View>
      </ScrollView>

      {/* Fixed Bottom Action Bar */}
      <View style={styles.bottomBar}>
        <TouchableOpacity
          style={[styles.primaryButton, { backgroundColor: color }]}
          activeOpacity={0.8}
          onPress={() =>
            Alert.alert('Mulai Belajar', `Selamat belajar modul ${title}!`)
          }
        >
          <Text style={styles.primaryButtonText}>Mulai Belajar Sekarang</Text>
          <Ionicons name="arrow-forward" size={18} color="#FFFFFF" />
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  topBar: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 16,
    paddingVertical: 14,
    backgroundColor: '#FFFFFF',
    borderBottomWidth: 1,
    borderColor: '#F1F5F9',
  },
  backButton: {
    padding: 4,
  },
  topBarTitle: {
    fontSize: 17,
    fontWeight: '700',
    color: '#0F172A',
  },
  shareBtn: {
    padding: 4,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 90,
  },
  bannerBox: {
    borderRadius: 20,
    padding: 24,
    alignItems: 'center',
    marginBottom: 16,
  },
  iconCircle: {
    width: 72,
    height: 72,
    borderRadius: 36,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  bannerCategory: {
    color: 'rgba(255, 255, 255, 0.85)',
    fontSize: 12,
    fontWeight: '700',
    textTransform: 'uppercase',
    letterSpacing: 1,
  },
  bannerTitle: {
    color: '#FFFFFF',
    fontSize: 22,
    fontWeight: '800',
    textAlign: 'center',
    marginTop: 4,
    marginBottom: 8,
  },
  bannerMeta: {
    color: 'rgba(255, 255, 255, 0.9)',
    fontSize: 13,
    fontWeight: '600',
  },
  infoCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    marginBottom: 16,
  },
  sectionHeaderTitle: {
    fontSize: 17,
    fontWeight: '700',
    color: '#0F172A',
    marginBottom: 10,
  },
  descriptionText: {
    fontSize: 14,
    color: '#475569',
    lineHeight: 22,
  },
  lessonsContainer: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 16,
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },
  lessonItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderColor: '#F1F5F9',
    gap: 12,
  },
  lessonNumBox: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#F1F5F9',
    alignItems: 'center',
    justifyContent: 'center',
  },
  lessonNumText: {
    fontSize: 13,
    fontWeight: '700',
    color: '#475569',
  },
  lessonInfo: {
    flex: 1,
  },
  lessonTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: '#0F172A',
    marginBottom: 2,
  },
  lessonDuration: {
    fontSize: 12,
    color: '#94A3B8',
  },
  bottomBar: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingVertical: 14,
    borderTopWidth: 1,
    borderColor: '#E2E8F0',
  },
  primaryButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    height: 48,
    borderRadius: 14,
    gap: 8,
  },
  primaryButtonText: {
    color: '#FFFFFF',
    fontSize: 15,
    fontWeight: '700',
  },
});
