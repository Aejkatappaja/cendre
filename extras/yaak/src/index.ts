import type { PluginDefinition } from '@yaakapp/api';
import { cendre } from './cendre';
import { cendreMedium } from './cendre-medium';
import { cendreSoft } from './cendre-soft';

export const plugin: PluginDefinition = {
  themes: [cendre, cendreMedium, cendreSoft],
};
