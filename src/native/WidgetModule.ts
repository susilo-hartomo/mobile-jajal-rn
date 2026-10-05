import { NativeModules, Platform } from 'react-native';

const { ZeniusWidgetBridge } = NativeModules;

export interface ZeniusWidgetData {
  streakDays?: number;
  currentSubject?: string;
  progressPercent?: number;
  nextClassTime?: string;
  quote?: string;
  minutesLearned?: number;
  pokemonAvatar?: string;
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

export const startPokemonPolling = async (
  intervalSeconds: number = 60
): Promise<boolean> => {
  if (Platform.OS !== 'ios') {
    return false;
  }
  try {
    if (ZeniusWidgetBridge && ZeniusWidgetBridge.startPokemonPolling) {
      await ZeniusWidgetBridge.startPokemonPolling(intervalSeconds);
      return true;
    }
  } catch (error) {
    console.warn('Failed to start Pokemon polling:', error);
  }
  return false;
};

export const stopPokemonPolling = async (): Promise<boolean> => {
  if (Platform.OS !== 'ios') {
    return false;
  }
  try {
    if (ZeniusWidgetBridge && ZeniusWidgetBridge.stopPokemonPolling) {
      await ZeniusWidgetBridge.stopPokemonPolling();
      return true;
    }
  } catch (error) {
    console.warn('Failed to stop Pokemon polling:', error);
  }
  return false;
};

export const rotateRandomPokemon = async (): Promise<string | null> => {
  if (Platform.OS !== 'ios') {
    return null;
  }
  try {
    if (ZeniusWidgetBridge && ZeniusWidgetBridge.rotateRandomPokemon) {
      const name = await ZeniusWidgetBridge.rotateRandomPokemon();
      return name;
    }
  } catch (error) {
    console.warn('Failed to rotate random Pokemon:', error);
  }
  return null;
};
