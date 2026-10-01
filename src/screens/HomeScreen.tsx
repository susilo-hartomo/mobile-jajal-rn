import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  StatusBar,
} from 'react-native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { useNavigation } from '@react-navigation/native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { RootStackParamList } from '../types/navigation';
import IPhoneWidgetSection from '../components/iPhoneWidgetSection';

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'MainTabs'>;

export interface SubjectItem {
  id: string;
  title: string;
  category: string;
  level: string;
  description: string;
  lessonsCount: number;
  iconName: string;
  color: string;
  bgColor: string;
}

const SUBJECTS: SubjectItem[] = [
  {
    id: '1',
    title: 'Matematika Murni & Terapan',
    category: 'Sains & Teknologi',
    level: 'SMA Kelas 12',
    description: 'Kuasai konsep aljabar, kalkulus, matriks, dan trigonometri dengan cara nalar Zenius.',
    lessonsCount: 42,
    iconName: 'calculator-outline',
    color: '#6366F1',
    bgColor: '#EEF2FF',
  },
  {
    id: '2',
    title: 'Fisika Dasar & Kuantum',
    category: 'Sains & Teknologi',
    level: 'SMA Kelas 12',
    description: 'Pahami hukum newton, termodinamika, gelombang, dan fisika modern secara mendalam.',
    lessonsCount: 36,
    iconName: 'atom-outline',
    color: '#0284C7',
    bgColor: '#E0F2FE',
  },
  {
    id: '3',
    title: 'Biologi & Genetika',
    category: 'Sains & Teknologi',
    level: 'SMA Kelas 11 & 12',
    description: 'Pelajari struktur sel, genetika populasi, fisiologi tumbuhan, dan ekosistem.',
    lessonsCount: 28,
    iconName: 'leaf-outline',
    color: '#16A34A',
    bgColor: '#DCFCE7',
  },
  {
    id: '4',
    title: 'Bahasa Indonesia & Literasi',
    category: 'Humaniora',
    level: 'Semua Tingkat',
    description: 'Keterampilan membaca kritis, analisis teks argumentasi, dan penalaran bacaan.',
    lessonsCount: 24,
    iconName: 'book-outline',
    color: '#EA580C',
    bgColor: '#FFEDD5',
  },
  {
    id: '5',
    title: 'Bahasa Inggris & Grammar',
    category: 'Bahasa & Komunikasi',
    level: 'Semua Tingkat',
    description: 'Kuasai Reading Comprehension, Structure, Vocabulary, dan Preparation UTBK.',
    lessonsCount: 30,
    iconName: 'globe-outline',
    color: '#DB2777',
    bgColor: '#FCE7F3',
  },
];

export default function HomeScreen() {
  const navigation = useNavigation<NavigationProp>();

  const handleSubjectPress = (subject: SubjectItem) => {
    navigation.navigate('Detail', {
      title: subject.title,
      category: subject.category,
      level: subject.level,
      description: subject.description,
      lessonsCount: subject.lessonsCount,
      iconName: subject.iconName,
      color: subject.color,
    });
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="dark-content" />
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Top Header */}
        <View style={styles.header}>
          <View>
            <Text style={styles.badgeText}>ZENIUS EDUCATION</Text>
            <Text style={styles.greetingTitle}>Halo, Zenius Student! 👋</Text>
            <Text style={styles.greetingSubtitle}>Siap belajar nalar hari ini?</Text>
          </View>
          <TouchableOpacity style={styles.notificationBtn} activeOpacity={0.7}>
            <Ionicons name="notifications-outline" size={22} color="#1E293B" />
          </TouchableOpacity>
        </View>

        {/* Hero Banner Card */}
        <View style={styles.heroCard}>
          <View style={styles.heroTextContainer}>
            <View style={styles.pillTag}>
              <Text style={styles.pillTagText}>UTBK & SNBT 2026</Text>
            </View>
            <Text style={styles.heroTitle}>Persiapan Lolos PTN Impian</Text>
            <Text style={styles.heroSubtitle}>
              Materi konsep nalar + ribuan latihan soal terlengkap.
            </Text>
            <TouchableOpacity style={styles.heroButton} activeOpacity={0.8}>
              <Text style={styles.heroButtonText}>Mulai Belajar Now</Text>
              <Ionicons name="arrow-forward" size={16} color="#FFFFFF" />
            </TouchableOpacity>
          </View>
        </View>

        {/* Interactive iPhone Widget Kit Section */}
        <IPhoneWidgetSection />

        {/* Section Header */}
        <View style={styles.sectionHeader}>
          <Text style={styles.sectionTitle}>Mata Pelajaran Populer</Text>
          <TouchableOpacity activeOpacity={0.7}>
            <Text style={styles.seeAllText}>Lihat Semua</Text>
          </TouchableOpacity>
        </View>

        {/* Subjects Grid */}
        <View style={styles.subjectList}>
          {SUBJECTS.map((item) => (
            <TouchableOpacity
              key={item.id}
              style={styles.subjectCard}
              activeOpacity={0.8}
              onPress={() => handleSubjectPress(item)}
            >
              <View style={[styles.iconBox, { backgroundColor: item.bgColor }]}>
                <Ionicons name={item.iconName} size={28} color={item.color} />
              </View>

              <View style={styles.subjectInfo}>
                <Text style={styles.categoryBadge}>{item.category}</Text>
                <Text style={styles.subjectTitle}>{item.title}</Text>
                <Text style={styles.subjectMeta}>
                  {item.level} • {item.lessonsCount} Video Modul
                </Text>
              </View>

              <Ionicons name="chevron-forward" size={20} color="#94A3B8" />
            </TouchableOpacity>
          ))}
        </View>
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 32,
  },
  header: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 20,
    marginTop: 8,
  },
  badgeText: {
    fontSize: 11,
    fontWeight: '800',
    color: '#6366F1',
    letterSpacing: 1,
    textTransform: 'uppercase',
  },
  greetingTitle: {
    fontSize: 22,
    fontWeight: '800',
    color: '#0F172A',
    marginTop: 2,
  },
  greetingSubtitle: {
    fontSize: 14,
    color: '#64748B',
    marginTop: 2,
  },
  notificationBtn: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: '#FFFFFF',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1,
    borderColor: '#E2E8F0',
  },

  // Hero Banner
  heroCard: {
    backgroundColor: '#4F46E5',
    borderRadius: 20,
    padding: 20,
    marginBottom: 24,
    shadowColor: '#4F46E5',
    shadowOffset: { width: 0, height: 6 },
    shadowOpacity: 0.25,
    shadowRadius: 12,
    elevation: 6,
  },
  heroTextContainer: {
    alignItems: 'flex-start',
  },
  pillTag: {
    backgroundColor: 'rgba(255, 255, 255, 0.2)',
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 12,
    marginBottom: 10,
  },
  pillTagText: {
    color: '#FFFFFF',
    fontSize: 11,
    fontWeight: '700',
    letterSpacing: 0.5,
  },
  heroTitle: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '800',
    marginBottom: 6,
  },
  heroSubtitle: {
    color: '#E0E7FF',
    fontSize: 13.5,
    lineHeight: 18,
    marginBottom: 16,
  },
  heroButton: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#312E81',
    paddingHorizontal: 16,
    paddingVertical: 10,
    borderRadius: 12,
    gap: 8,
  },
  heroButtonText: {
    color: '#FFFFFF',
    fontSize: 13,
    fontWeight: '700',
  },

  // Section Header
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 14,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '700',
    color: '#0F172A',
  },
  seeAllText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#4F46E5',
  },

  // Subject Card
  subjectList: {
    gap: 12,
  },
  subjectCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 14,
    borderWidth: 1,
    borderColor: '#F1F5F9',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.03,
    shadowRadius: 8,
    elevation: 2,
    gap: 12,
  },
  iconBox: {
    width: 52,
    height: 52,
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
  },
  subjectInfo: {
    flex: 1,
  },
  categoryBadge: {
    fontSize: 11,
    fontWeight: '700',
    color: '#64748B',
    marginBottom: 2,
  },
  subjectTitle: {
    fontSize: 15,
    fontWeight: '700',
    color: '#0F172A',
    marginBottom: 4,
  },
  subjectMeta: {
    fontSize: 12,
    color: '#94A3B8',
  },
});
