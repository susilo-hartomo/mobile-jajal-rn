import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TextInput,
  TouchableOpacity,
} from 'react-native';
import Ionicons from 'react-native-vector-icons/Ionicons';
import { useNavigation } from '@react-navigation/native';
import { NativeStackNavigationProp } from '@react-navigation/native-stack';
import { RootStackParamList } from '../types/navigation';

type NavigationProp = NativeStackNavigationProp<RootStackParamList, 'MainTabs'>;

const CATEGORIES = ['Semua', 'Saintek', 'Soshum', 'UTBK SNBT', 'Bahasa'];

const COURSES_DATA = [
  {
    id: 'c1',
    title: 'Kalkulus & Matriks dasar',
    category: 'Saintek',
    lessons: 18,
    duration: '4 jam 20 menit',
    rating: 4.9,
    iconName: 'calculator-outline',
    color: '#6366F1',
    bgColor: '#EEF2FF',
    description: 'Modul konsep kalkulus diferensial, integral, dan operasi matriks.',
  },
  {
    id: 'c2',
    title: 'Mekanika & Gaya Fisika',
    category: 'Saintek',
    lessons: 15,
    duration: '3 jam 45 menit',
    rating: 4.8,
    iconName: 'atom-outline',
    color: '#0284C7',
    bgColor: '#E0F2FE',
    description: 'Kinematika gerak lurus, hukum Newton, dan hukum kekekalan energi.',
  },
  {
    id: 'c3',
    title: 'Penalaran Umum UTBK',
    category: 'UTBK SNBT',
    lessons: 22,
    duration: '5 jam 10 menit',
    rating: 4.95,
    iconName: 'sparkles-outline',
    color: '#F59E0B',
    bgColor: '#FEF3C7',
    description: 'Latihan nalar deduktif, induktif, dan pemahaman logika penalaran.',
  },
  {
    id: 'c4',
    title: 'Sejarah & Geografi Dunia',
    category: 'Soshum',
    lessons: 12,
    duration: '2 jam 50 menit',
    rating: 4.7,
    iconName: 'compass-outline',
    color: '#10B981',
    bgColor: '#D1FAE5',
    description: 'Sejarah peradaban manusia, peta geopolitik, dan iklim bumi.',
  },
];

export default function CoursesScreen() {
  const navigation = useNavigation<NavigationProp>();
  const [selectedCategory, setSelectedCategory] = useState('Semua');
  const [searchQuery, setSearchQuery] = useState('');

  const filteredCourses = COURSES_DATA.filter((course) => {
    const matchesCategory =
      selectedCategory === 'Semua' || course.category === selectedCategory;
    const matchesQuery = course.title
      .toLowerCase()
      .includes(searchQuery.toLowerCase());
    return matchesCategory && matchesQuery;
  });

  return (
    <View style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Katalog Pembelajaran</Text>
        <Text style={styles.headerSubtitle}>
          Pilih modul materi nalar sesuai kebutuhanmu
        </Text>

        {/* Search Bar */}
        <View style={styles.searchBar}>
          <Ionicons name="search-outline" size={20} color="#94A3B8" />
          <TextInput
            style={styles.searchInput}
            placeholder="Cari materi atau mata pelajaran..."
            placeholderTextColor="#94A3B8"
            value={searchQuery}
            onChangeText={setSearchQuery}
          />
        </View>

        {/* Category Pills */}
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          contentContainerStyle={styles.categoriesScroll}
        >
          {CATEGORIES.map((cat) => (
            <TouchableOpacity
              key={cat}
              activeOpacity={0.8}
              style={[
                styles.categoryPill,
                selectedCategory === cat && styles.activeCategoryPill,
              ]}
              onPress={() => setSelectedCategory(cat)}
            >
              <Text
                style={[
                  styles.categoryText,
                  selectedCategory === cat && styles.activeCategoryText,
                ]}
              >
                {cat}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>
      </View>

      {/* Courses List */}
      <ScrollView
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.listContent}
      >
        {filteredCourses.map((course) => (
          <TouchableOpacity
            key={course.id}
            style={styles.courseCard}
            activeOpacity={0.8}
            onPress={() =>
              navigation.navigate('Detail', {
                title: course.title,
                category: course.category,
                level: 'SMA & UTBK',
                description: course.description,
                lessonsCount: course.lessons,
                iconName: course.iconName,
                color: course.color,
              })
            }
          >
            <View
              style={[styles.courseIconBox, { backgroundColor: course.bgColor }]}
            >
              <Ionicons name={course.iconName} size={30} color={course.color} />
            </View>

            <View style={styles.courseInfo}>
              <View style={styles.badgeRow}>
                <Text style={styles.categoryLabel}>{course.category}</Text>
                <View style={styles.ratingBadge}>
                  <Ionicons name="star" size={12} color="#F59E0B" />
                  <Text style={styles.ratingText}>{course.rating}</Text>
                </View>
              </View>

              <Text style={styles.courseTitle}>{course.title}</Text>

              <View style={styles.metaRow}>
                <View style={styles.metaItem}>
                  <Ionicons name="play-circle-outline" size={14} color="#64748B" />
                  <Text style={styles.metaText}>{course.lessons} Video</Text>
                </View>
                <View style={styles.metaItem}>
                  <Ionicons name="time-outline" size={14} color="#64748B" />
                  <Text style={styles.metaText}>{course.duration}</Text>
                </View>
              </View>
            </View>
          </TouchableOpacity>
        ))}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F8FAFC',
  },
  header: {
    backgroundColor: '#FFFFFF',
    paddingHorizontal: 16,
    paddingTop: 20,
    paddingBottom: 12,
    borderBottomWidth: 1,
    borderColor: '#F1F5F9',
  },
  headerTitle: {
    fontSize: 22,
    fontWeight: '800',
    color: '#0F172A',
  },
  headerSubtitle: {
    fontSize: 13,
    color: '#64748B',
    marginTop: 2,
    marginBottom: 14,
  },
  searchBar: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#F1F5F9',
    borderRadius: 12,
    paddingHorizontal: 12,
    height: 44,
    gap: 8,
    marginBottom: 14,
  },
  searchInput: {
    flex: 1,
    fontSize: 14,
    color: '#0F172A',
  },
  categoriesScroll: {
    gap: 8,
    paddingRight: 16,
  },
  categoryPill: {
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderRadius: 20,
    backgroundColor: '#F1F5F9',
  },
  activeCategoryPill: {
    backgroundColor: '#4F46E5',
  },
  categoryText: {
    fontSize: 13,
    fontWeight: '600',
    color: '#64748B',
  },
  activeCategoryText: {
    color: '#FFFFFF',
  },
  listContent: {
    padding: 16,
    gap: 12,
  },
  courseCard: {
    flexDirection: 'row',
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 14,
    borderWidth: 1,
    borderColor: '#E2E8F0',
    gap: 12,
    alignItems: 'center',
  },
  courseIconBox: {
    width: 60,
    height: 60,
    borderRadius: 16,
    alignItems: 'center',
    justifyContent: 'center',
  },
  courseInfo: {
    flex: 1,
  },
  badgeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginBottom: 4,
  },
  categoryLabel: {
    fontSize: 11,
    fontWeight: '700',
    color: '#6366F1',
    textTransform: 'uppercase',
  },
  ratingBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
  },
  ratingText: {
    fontSize: 12,
    fontWeight: '700',
    color: '#0F172A',
  },
  courseTitle: {
    fontSize: 15,
    fontWeight: '700',
    color: '#0F172A',
    marginBottom: 6,
  },
  metaRow: {
    flexDirection: 'row',
    gap: 14,
  },
  metaItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 4,
  },
  metaText: {
    fontSize: 12,
    color: '#64748B',
  },
});
