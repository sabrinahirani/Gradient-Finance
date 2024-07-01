import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';

import { ChakraProvider } from '@chakra-ui/react';
import theme from './theme';
import './styles.scss'

import Home from './components/Home';
import Placeholder from './components/Placeholder';

function App() {
  return (
    <ChakraProvider theme={theme}>
      <Router>
        <Routes>
          <Route path="*" element={<Home />} />
          <Route path="/mint" element={<Placeholder />} />
          <Route path="/trade" element={<Placeholder />} />
          <Route path="/derivatives" element={<Placeholder />} />
        </Routes>
      </Router>
    </ChakraProvider>
  );
}

export default App;