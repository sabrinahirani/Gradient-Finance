import { extendTheme } from '@chakra-ui/react';

import '@fontsource/inter';

const theme = extendTheme({
  fonts: {
    heading: `'Inter', sans-serif`,
    body: `'Inter', sans-serif`,
  },
  colors: {
    gradient: {
      500: '#019b7a',
    },
  },
});

export default theme;