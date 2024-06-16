import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

import { ChakraProvider } from '@chakra-ui/react';
import theme from './theme';
import './styles.scss'

import Home from './components/Home';
import MintGRADC from './components/MintGRADC';
import MintSA from './components/MintSA';

function App() {
  return (
    <ChakraProvider theme={theme}>
      <Router>
        <Routes>
          <Route path="*" element={<Home />} />
          <Route path="/mint-gradc" element={<MintGRADC />} />
          <Route path="/mint-sa" element={<MintSA />} />
        </Routes>
      </Router>
    </ChakraProvider>
  );
}

export default App;