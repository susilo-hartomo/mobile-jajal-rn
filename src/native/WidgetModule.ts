import { NativeModules, Platform } from 'react-native';

const { ZeniusWidgetBridge } = NativeModules;

export interface ZeniusWidgetData {
  streakDays?: number;
  currentSubject?: string;
  progressPercent?: number;
  nextClassTime?: string;
  quote?: string;
}

export const updateZeniusWidget = async (
  data: ZeniusWidgetData
): Promise<boolean> => {
  if (Platform.OS !== 'ios') {
    return false;
  }
  try {
    if (ZeniusWidgetBridge && ZeniusWidgetBridge.updateWidgetData) {
      await ZeniusWidgetBridge.updateWidgetData(data);
      return true;
    }
  } catch (error) {
    console.warn('Failed to update iOS Zenius Widget:', error);
  }
  return false;
};

export const reloadZeniusWidget = async (): Promise<boolean> => {
  if (Platform.OS !== 'ios') {
    return false;
  }
  try {
    if (ZeniusWidgetBridge && ZeniusWidgetBridge.reloadWidget) {
      await ZeniusWidgetBridge.reloadWidget();
      return true;
    }
  } catch (error) {
    console.warn('Failed to reload iOS Zenius Widget:', error);
  }
  return false;
};
