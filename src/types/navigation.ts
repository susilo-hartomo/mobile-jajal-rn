export type RootStackParamList = {
  MainTabs: undefined;
  Detail: {
    title: string;
    category: string;
    level: string;
    description: string;
    lessonsCount: number;
    iconName: string;
    color: string;
  };
};

export type MainTabParamList = {
  Home: undefined;
  Courses: undefined;
  Profile: undefined;
};
